import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/image_upload/constants/constants.dart';
import 'package:tekk_gram/state/image_upload/exceptions/could_not_build_thumbnail_exception.dart';
import 'package:tekk_gram/state/image_upload/extensions/get_collection_name_from_file_type.dart';
import 'package:tekk_gram/state/image_upload/extensions/get_image_data_aspect_ratio.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/image_upload/typedefs/is_loading.dart';
import 'package:tekk_gram/state/posts/models/post_key.dart';
import 'package:tekk_gram/state/posts/typedefs/post_id.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class EditPostNotifier extends StateNotifier<IsLoading> {
  EditPostNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> editPost({
    required UserId userId,
    required PostId postId,
    required String message,
    File? file,
    required FileType fileType,
    required String originalFileStorageId,
    required String thumbnailStorageId,
  }) async {
    try {
      isLoading = true;
      log(postId);

      final postData = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.posts)
          .where(FieldPath.documentId, isEqualTo: postId)
          .limit(1)
          .get();

      final post = postData.docs.where((data) => data.id == postId);
      if (post.isNotEmpty) {
        await post.first.reference.update({
          "message": message,
        });
      }
      return true;
    } catch (e) {
      log("THIS IS TEH ERROR: $e");
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool?> editImagePost({
    required UserId userId,
    required PostId postId,
    required String message,
    required List<File> files,
    required FileType fileType,
    required List<String> originalFileStorageId,
    required List<String> thumbnailStorageId,
  }) async {
    List<String> thumbnailStorageIdList = [];
    List<String> originalStorageIdList = [];
    List<Reference> thumbnailReferenceList = [];
    List<Reference> originalReferenceList = [];
    List<String> fileNameList = [];
    List<double> thumbnailAspectRatioList = [];
    List<String> thumbnailUrlList = [];
    List<String> originalUrlList = [];

    isLoading = true;

    try {
      final postData = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.posts)
          .where(FieldPath.documentId, isEqualTo: postId)
          .limit(1)
          .get();

      final post = postData.docs.where((data) => data.id == postId);
      if (post.isNotEmpty) {
        late Uint8List thumbnailUint8List;

        await Future.forEach(files, (file) async {
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
              break;
          }

          // calculate the aspect ratio
          final thumbnailAspectRatio = await thumbnailUint8List.getAspectRatio();
          log("Thumbnail aspect ratio: $thumbnailAspectRatio");
          // calculate references
          thumbnailAspectRatioList.add(thumbnailAspectRatio);

          final fileName = const Uuid().v4();
          fileNameList.add(fileName);

          // create references to the thumbnail and the image itself
          final thumbnailRef =
              FirebaseStorage.instance.ref().child(userId).child(FirebaseCollectionName.thumbnails).child(fileName);
          log("Thumbnail ref: $thumbnailRef");
          thumbnailReferenceList.add(thumbnailRef);

          final originalFileRef =
              FirebaseStorage.instance.ref().child(userId).child(fileType.collectionName).child(fileName);
          originalReferenceList.add(originalFileRef);
          log("Original ref: $originalFileRef");

          // FirebaseStorage.instance
          //     .ref()
          //     .child(userId)
          //     .child(FirebaseCollectionName.thumbnails)
          //     .child(thumbnailStorageId)
          //     .delete()
          //     .then((value) {
          //   FirebaseStorage.instance
          //       .ref()
          //       .child(userId)
          //       .child(fileType.collectionName)
          //       .child(originalFileStorageId)
          //       .delete()
          //       .then((value) async {

          //     return true;
          //   });
          // });

          final thumbnailUploadTask = await thumbnailRef.putData(thumbnailUint8List);
          final thumbnailStorageId = thumbnailUploadTask.ref.name;
          thumbnailStorageIdList.add(thumbnailStorageId);
          final thumbUrl = await thumbnailUploadTask.ref.getDownloadURL();
          thumbnailUrlList.add(thumbUrl);
          // upload the original image
          final originalFileUploadTask = await originalFileRef.putFile(file);
          final originalFileStorageId = originalFileUploadTask.ref.name;
          originalStorageIdList.add(originalFileStorageId);
          final orgUrl = await originalFileUploadTask.ref.getDownloadURL();
          originalUrlList.add(orgUrl);
        });

        await postData.docs.first.reference.update({
          PostKey.userId: userId,
          PostKey.message: message,
          PostKey.thumbnailUrl: thumbnailUrlList,
          PostKey.fileUrl: originalUrlList,
          PostKey.fileType: fileType.name,
          PostKey.fileName: fileNameList,
          PostKey.aspectRatio: thumbnailAspectRatioList,
          PostKey.thumbnailStorageId: thumbnailStorageIdList,
          PostKey.originalFileStorageId: originalStorageIdList,
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log("THIS IS TEH ERROR: $e");
      return false;
    } finally {
      isLoading = false;
    }
  }
}
