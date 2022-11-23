import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
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
import 'package:image/image.dart' as img;
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
        if (file == null) {
          await post.first.reference.update({
            "message": message,
          });
        } else {
          log("TO DELETE IMAGE: $originalFileStorageId");

          // delete post original file
          await FirebaseStorage.instance
              .ref()
              .child(userId)
              .child(fileType.collectionName)
              .child(originalFileStorageId)
              .delete();

          //delete the post thumbnail
          await FirebaseStorage.instance
              .ref()
              .child(userId)
              .child(FirebaseCollectionName.thumbnails)
              .child(thumbnailStorageId)
              .delete();

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
              break;
          }

          // calculate the aspect ratio
          final thumbnailAspectRatio = await thumbnailUint8List.getAspectRatio();
          log("THIS: $thumbnailAspectRatio");

          // calculate references
          final fileName = const Uuid().v4();

          log("THIS: $fileName");
          // create references to the thumbnail and the image itself
          final thumbnailRef =
              FirebaseStorage.instance.ref().child(userId).child(FirebaseCollectionName.thumbnails).child(fileName);
          log("THIS: $thumbnailRef");

          final originalFileRef =
              FirebaseStorage.instance.ref().child(userId).child(fileType.collectionName).child(fileName);
          log("THIS: $originalFileRef");

          try {
            // upload the original image
            await originalFileRef.putFile(file).then((data) async {
              log("Or: $data");

              final originalFileStorageId = data.ref.name;
              log("Or: $originalFileStorageId");
              // upload the thumbnai
              await thumbnailRef.putData(thumbnailUint8List).then((p0) async {
                final thumbnailStorageId = p0.ref.name;
                log("THIS: $thumbnailStorageId");

                // log("ORIGINAL REF: ${await originalFileRef.getDownloadURL()}");

                await post.first.reference.update({
                  PostKey.message: message,
                  PostKey.aspectRatio: thumbnailAspectRatio,
                  PostKey.thumbnailStorageId: thumbnailStorageId,
                  PostKey.originalFileStorageId: originalFileStorageId,
                  PostKey.fileType: fileType,
                  PostKey.thumbnailUrl: await thumbnailRef.getDownloadURL(),
                  PostKey.fileUrl: await originalFileRef.getDownloadURL(),
                });
              });
            });

            return true;
          } catch (e) {
            log("THIS IS TEH ERROR: $e");

            return false;
          } finally {
            isLoading = false;
          }
        }
      }
      return true;
    } catch (e) {
      log("THIS IS TEH ERROR: $e");
      return false;
    } finally {
      isLoading = false;
    }
  }
}
