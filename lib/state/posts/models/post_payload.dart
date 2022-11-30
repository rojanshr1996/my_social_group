import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:flutter/foundation.dart' show immutable;
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/post_settings/models/post_settings.dart';
import 'package:tekk_gram/state/posts/models/post_key.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';

@immutable
// class PostPayload extends MapView<String, dynamic> {
//   PostPayload({
//     required UserId userId,
//     required String message,
//     required String thumbnailUrl,
//     required String fileUrl,
//     required FileType fileType,
//     required String fileName,
//     required double aspectRatio,
//     required String thumbnailStorageId,
//     required String originalFileStorageId,
//     FieldValue? createdAt,
//     required Map<PostSettings, bool> postSettings,
//   }) : super(
//           {
//             PostKey.userId: userId,
//             PostKey.message: message,
//             PostKey.createdAt: createdAt ?? FieldValue.serverTimestamp(),
//             PostKey.thumbnailUrl: thumbnailUrl,
//             PostKey.fileUrl: fileUrl,
//             PostKey.fileType: fileType.name,
//             PostKey.fileName: fileName,
//             PostKey.aspectRatio: aspectRatio,
//             PostKey.thumbnailStorageId: thumbnailStorageId,
//             PostKey.originalFileStorageId: originalFileStorageId,
//             PostKey.postSettings: {
//               for (final postSetting in postSettings.entries) postSetting.key.storageKey: postSetting.value,
//             },
//           },
//         );
// }

class PostPayload extends MapView<String, dynamic> {
  PostPayload({
    required UserId userId,
    required String message,
    required List<String> thumbnailUrl,
    required List<String> fileUrl,
    required FileType fileType,
    required List<String> fileName,
    required List<double> aspectRatio,
    required List<String> thumbnailStorageId,
    required List<String> originalFileStorageId,
    FieldValue? createdAt,
    required Map<PostSettings, bool> postSettings,
  }) : super(
          {
            PostKey.userId: userId,
            PostKey.message: message,
            PostKey.createdAt: createdAt ?? FieldValue.serverTimestamp(),
            PostKey.thumbnailUrl: thumbnailUrl,
            PostKey.fileUrl: fileUrl,
            PostKey.fileType: fileType.name,
            PostKey.fileName: fileName,
            PostKey.aspectRatio: aspectRatio,
            PostKey.thumbnailStorageId: thumbnailStorageId,
            PostKey.originalFileStorageId: originalFileStorageId,
            PostKey.postSettings: {
              for (final postSetting in postSettings.entries) postSetting.key.storageKey: postSetting.value,
            },
          },
        );
}
