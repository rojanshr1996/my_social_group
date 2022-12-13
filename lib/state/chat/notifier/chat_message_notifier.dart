import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/chat/models/chat_payload.dart';
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/image_upload/constants/constants.dart';
import 'package:tekk_gram/state/image_upload/extensions/get_image_data_aspect_ratio.dart';
import 'package:tekk_gram/state/image_upload/typedefs/is_loading.dart';
import 'package:uuid/uuid.dart';

class ChatMessageNotifier extends StateNotifier<IsLoading> {
  ChatMessageNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> sendMessage({
    required String groupChatId,
    required String currentUserId,
    required String receiverId,
    required String message,
    String? type,
    List<File> files = const [],
  }) async {
    isLoading = true;
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection(FirebaseCollectionName.chat)
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      if (files.isEmpty) {
        ChatPayload messageChat = ChatPayload(
          sender: currentUserId,
          receiver: receiverId,
          createdAt: FieldValue.serverTimestamp(),
          message: message,
          type: "text",
        );
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(
            documentReference,
            messageChat,
          );
        });
      } else {
        List<String> thumbnailStorageIdList = [];
        List<String> originalStorageIdList = [];
        List<Reference> thumbnailReferenceList = [];
        List<Reference> originalReferenceList = [];
        List<String> fileNameList = [];
        List<double> thumbnailAspectRatioList = [];
        List<String> thumbnailUrlList = [];
        List<String> originalUrlList = [];

        final result = await Future.forEach(
          files,
          (imageFile) async {
            // isLoading = true;
            late Uint8List thumbnailUint8List;

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
            log("Thumbnail Data: $thumbnail");

            // calculate the aspect ratio
            final thumbnailAspectRatio = await thumbnailUint8List.getAspectRatio();

            thumbnailAspectRatioList.add(thumbnailAspectRatio);
            log("THumbnail Aspect Ratio: $thumbnailAspectRatio");

            // calculate references
            final fileName = const Uuid().v4();
            fileNameList.add(const Uuid().v4());
            log("File Name List: $fileNameList");

            // create references to the thumbnail and the image itself
            final thumbnailRef = FirebaseStorage.instance
                .ref()
                .child(currentUserId)
                .child(FirebaseCollectionName.thumbnails)
                .child(fileName);
            thumbnailReferenceList.add(thumbnailRef);

            // log("Thumbnail URL List: $thumbnailRef");

            final originalFileRef =
                FirebaseStorage.instance.ref().child(currentUserId).child(FirebaseCollectionName.chat).child(fileName);
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

        ChatPayload messageChat = ChatPayload(
          sender: currentUserId,
          receiver: receiverId,
          createdAt: FieldValue.serverTimestamp(),
          message: message,
          type: "images",
          aspectRatio: thumbnailAspectRatioList,
          thumbnailUrl: thumbnailUrlList,
          fileUrl: originalUrlList,
          fileName: fileNameList,
          thumbnailStorageId: thumbnailStorageIdList,
          originalFileStorageId: originalStorageIdList,
        );
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(
            documentReference,
            messageChat,
          );
        });
      }

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
