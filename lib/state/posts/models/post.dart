import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/post_settings/models/post_settings.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:tekk_gram/state/posts/models/post_key.dart';

@immutable
class Post {
  final String postId;
  final String userId;
  final String message;
  final DateTime? createdAt;
  final List<String> thumbnailUrl;
  final List<String> fileUrl;
  final FileType fileType;
  final List<String> fileName;
  final List<double> aspectRatio;
  final List<String> thumbnailStorageId;
  final List<String> originalFileStorageId;
  final Map<PostSettings, bool> postSettings;

  Post({
    required this.postId,
    required Map<String, dynamic> json,
  })  : userId = json[PostKey.userId],
        message = json[PostKey.message],
        createdAt = json[PostKey.createdAt] == null ? null : (json[PostKey.createdAt] as Timestamp).toDate(),
        thumbnailUrl = (json[PostKey.thumbnailUrl] as List).map((item) => item as String).toList(),
        fileUrl = (json[PostKey.fileUrl] as List).map((item) => item as String).toList(),
        fileType = FileType.values.firstWhere(
          (fileType) => fileType.name == json[PostKey.fileType],
          orElse: () => FileType.image,
        ),
        fileName = (json[PostKey.fileName] as List).map((item) => item as String).toList(),
        aspectRatio = (json[PostKey.aspectRatio] as List).map((item) => item as double).toList(),
        thumbnailStorageId = (json[PostKey.thumbnailStorageId] as List).map((item) => item as String).toList(),
        originalFileStorageId = (json[PostKey.originalFileStorageId] as List).map((item) => item as String).toList(),
        postSettings = {
          for (final entry in json[PostKey.postSettings].entries)
            PostSettings.values.firstWhere(
              (element) => element.storageKey == entry.key,
            ): entry.value,
        };

  bool get allowsLikes => postSettings[PostSettings.allowLikes] ?? false;
  bool get allowsComments => postSettings[PostSettings.allowComments] ?? false;
}


// @immutable
// class Post {
//   final String postId;
//   final String userId;
//   final String message;
//   final DateTime createdAt;
//   final String thumbnailUrl;
//   final String fileUrl;
//   final FileType fileType;
//   final String fileName;
//   final double aspectRatio;
//   final String thumbnailStorageId;
//   final String originalFileStorageId;
//   final Map<PostSettings, bool> postSettings;

//   Post({
//     required this.postId,
//     required Map<String, dynamic> json,
//   })  : userId = json[PostKey.userId],
//         message = json[PostKey.message],
//         createdAt = (json[PostKey.createdAt] as Timestamp).toDate(),
//         thumbnailUrl = json[PostKey.thumbnailUrl],
//         fileUrl = json[PostKey.fileUrl],
//         fileType = FileType.values.firstWhere(
//           (fileType) => fileType.name == json[PostKey.fileType],
//           orElse: () => FileType.image,
//         ),
//         fileName = json[PostKey.fileName],
//         aspectRatio = json[PostKey.aspectRatio],
//         thumbnailStorageId = json[PostKey.thumbnailStorageId],
//         originalFileStorageId = json[PostKey.originalFileStorageId],
//         postSettings = {
//           for (final entry in json[PostKey.postSettings].entries)
//             PostSettings.values.firstWhere(
//               (element) => element.storageKey == entry.key,
//             ): entry.value,
//         };

//   bool get allowsLikes => postSettings[PostSettings.allowLikes] ?? false;
//   bool get allowsComments => postSettings[PostSettings.allowComments] ?? false;
// }
