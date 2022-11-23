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
          thumbnailUrl: await thumbnailRef.getDownloadURL(),
          fileUrl: await originalFileRef.getDownloadURL(),
          fileType: fileType,
          fileName: fileName,
          aspectRatio: thumbnailAspectRatio,
          postSettings: postSettings!,
          thumbnailStorageId: thumbnailStorageId,
          originalFileStorageId: originalFileStorageId,
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
}
