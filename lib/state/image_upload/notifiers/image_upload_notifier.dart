import 'dart:developer';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/image_upload/constants/constants.dart';
import 'package:tekk_gram/state/image_upload/exceptions/could_not_build_thumbnail_exception.dart';
import 'package:tekk_gram/state/image_upload/extensions/get_collection_name_from_file_type.dart';
import 'package:tekk_gram/state/image_upload/extensions/get_image_data_aspect_ratio.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/image_upload/typedefs/is_loading.dart';
import 'package:tekk_gram/state/post_settings/models/post_settings.dart';
import 'package:tekk_gram/state/posts/models/post_payload.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ImageUploadNotifier extends StateNotifier<IsLoading> {
  ImageUploadNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> upload({
    required File file,
    required FileType fileType,
    String? message,
    Map<PostSettings, bool>? postSettings,
    required String userId,
    UserInfoModel? userData,
  }) async {
    isLoading = true;
    late Uint8List thumbnailUint8List;

    switch (fileType) {
      case FileType.image:
        // create a thumbnail out of the file
        final fileAsImage = img.decodeImage(file.readAsBytesSync());
        if (fileAsImage == null) {
          isLoading = false;
          return false;
        }
        // create thumbnail
        final thumbnail = img.copyResize(
          fileAsImage,
          width: Constants.imageThumbnailWidth,
        );
        final thumbnailData = img.encodeJpg(thumbnail);
        thumbnailUint8List = Uint8List.fromList(thumbnailData);
        break;
      case FileType.video:
        final thumb = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: Constants.videoThumbnailMaxHeight,
          quality: Constants.videoThumbnailMaxQuality,
        );
        if (thumb == null) {
          isLoading = false;
          throw const CouldNotBuildThumbnailException();
        } else {
          thumbnailUint8List = thumb;
        }
        break;
      case FileType.userImage:
        // create a thumbnail out of the file
        final fileAsImage = img.decodeImage(file.readAsBytesSync());
        if (fileAsImage == null) {
          isLoading = false;
          return false;
        }
        // create thumbnail
        final thumbnail = img.copyResize(
          fileAsImage,
          width: Constants.imageThumbnailWidth,
        );
        final thumbnailData = img.encodeJpg(thumbnail);
        thumbnailUint8List = Uint8List.fromList(thumbnailData);
        break;
    }
    // calculate the aspect ratio
    final thumbnailAspectRatio = await thumbnailUint8List.getAspectRatio();

    // calculate references
    final fileName = const Uuid().v4();

    // create references to the thumbnail and the image itself
    final thumbnailRef =
        FirebaseStorage.instance.ref().child(userId).child(FirebaseCollectionName.thumbnails).child(fileName);

    final originalFileRef = FirebaseStorage.instance.ref().child(userId).child(fileType.collectionName).child(fileName);
    try {
      // upload the thumbnai
      final thumbnailUploadTask = await thumbnailRef.putData(thumbnailUint8List);
      final thumbnailStorageId = thumbnailUploadTask.ref.name;

      // upload the original image
      final originalFileUploadTask = await originalFileRef.putFile(file);
      final originalFileStorageId = originalFileUploadTask.ref.name;

      if (fileType == FileType.userImage) {
        final userInfo = await FirebaseFirestore.instance
            .collection(
              FirebaseCollectionName.users,
            )
            .where(FirebaseFieldName.userId, isEqualTo: userId)
            .limit(1)
            .get();
        await userInfo.docs.first.reference.update({
          FirebaseFieldName.displayName: userData?.displayName,
          FirebaseFieldName.email: userData?.email ?? '',
          FirebaseFieldName.phone: userData?.phone ?? '',
          FirebaseFieldName.imageUrl: await originalFileRef.getDownloadURL(),
        });
        return true;
      } else {
        // upload the post itself
        final postPayload = PostPayload(
          userId: userId,
          message: message ?? "",
          thumbnailUrl: [await thumbnailRef.getDownloadURL()],
          fileUrl: [await originalFileRef.getDownloadURL()],
          fileType: fileType,
          fileName: [fileName],
          aspectRatio: [thumbnailAspectRatio],
          postSettings: postSettings!,
          thumbnailStorageId: [thumbnailStorageId],
          originalFileStorageId: [originalFileStorageId],
          createdAt: FieldValue.serverTimestamp(),
        );
        await FirebaseFirestore.instance.collection(FirebaseCollectionName.posts).add(postPayload);
        return true;
      }
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> uploadMultipleImageFiles({
    required List<File> files,
    String? message,
    Map<PostSettings, bool>? postSettings,
    required FileType fileType,
    required String userId,
    UserInfoModel? userData,
  }) async {
    isLoading = true;
    List<String> thumbnailStorageIdList = [];
    List<String> originalStorageIdList = [];
    List<Reference> thumbnailReferenceList = [];
    List<Reference> originalReferenceList = [];
    List<String> fileNameList = [];
    List<double> thumbnailAspectRatioList = [];
    List<String> thumbnailUrlList = [];
    List<String> originalUrlList = [];

    int counter = 0;
    try {
      // ignore: unused_local_variable
      final result = await Future.forEach(
        files,
        (imageFile) async {
          log("IMAGE UPLOAD COUNTER: ${counter++}");
          // isLoading = true;
          late Uint8List thumbnailUint8List;

          // create a thumbnail out of the file
          final fileAsImage = img.decodeImage(imageFile.readAsBytesSync());
          log("FILE AS IMAGE: $fileAsImage");

          if (fileAsImage == null) {
            log("Run null value");

            isLoading = false;
            return false;
          }
          switch (fileType) {
            case FileType.image:
              // create a thumbnail out of the file
              final fileAsImage = img.decodeImage(imageFile.readAsBytesSync());
              if (fileAsImage == null) {
                isLoading = false;
                return false;
              }
              // create thumbnail
              final thumbnail = img.copyResize(
                fileAsImage,
                width: Constants.imageThumbnailWidth,
              );
              final thumbnailData = img.encodeJpg(thumbnail);
              thumbnailUint8List = Uint8List.fromList(thumbnailData);
              log("THumbnail Data: $thumbnail");
              break;
            case FileType.video:
              break;
            case FileType.userImage:
              break;
          }

          // calculate the aspect ratio
          final thumbnailAspectRatio = await thumbnailUint8List.getAspectRatio();

          thumbnailAspectRatioList.add(thumbnailAspectRatio);
          log("THumbnail Aspect Ratio: $thumbnailAspectRatio");

          // calculate references
          final fileName = const Uuid().v4();
          fileNameList.add(const Uuid().v4());
          log("File Name List: $fileNameList");

          // create references to the thumbnail and the image itself
          final thumbnailRef =
              FirebaseStorage.instance.ref().child(userId).child(FirebaseCollectionName.thumbnails).child(fileName);
          thumbnailReferenceList.add(thumbnailRef);

          // log("Thumbnail URL List: $thumbnailRef");

          final originalFileRef =
              FirebaseStorage.instance.ref().child(userId).child(fileType.collectionName).child(fileName);
          originalReferenceList.add(originalFileRef);

          // log("ORIGINAL URL List: $originalFileRef");

          try {
            // upload the thumbnai
            final thumbnailUploadTask = await thumbnailRef.putData(thumbnailUint8List);
            final thumbnailStorageId = thumbnailUploadTask.ref.name;
            thumbnailStorageIdList.add(thumbnailStorageId);
            final thumbUrl = await thumbnailUploadTask.ref.getDownloadURL();
            thumbnailUrlList.add(thumbUrl);

            // upload the original image
            final originalFileUploadTask = await originalFileRef.putFile(imageFile);
            final originalFileStorageId = originalFileUploadTask.ref.name;
            originalStorageIdList.add(originalFileStorageId);
            final orgUrl = await originalFileUploadTask.ref.getDownloadURL();
            originalUrlList.add(orgUrl);
          } catch (_) {
            return false;
          }
          return originalUrlList;
        },
      );

      final postPayload = PostPayload(
        userId: userId,
        message: message ?? "",
        thumbnailUrl: thumbnailUrlList,
        fileUrl: originalUrlList,
        fileType: fileType,
        fileName: fileNameList,
        aspectRatio: thumbnailAspectRatioList,
        postSettings: postSettings!,
        thumbnailStorageId: thumbnailStorageIdList,
        originalFileStorageId: originalStorageIdList,
        createdAt: FieldValue.serverTimestamp(),
      );
      log("PayLOAD: $postPayload");

      await FirebaseFirestore.instance.collection(FirebaseCollectionName.posts).add(postPayload);
      // isLoading = false;
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
