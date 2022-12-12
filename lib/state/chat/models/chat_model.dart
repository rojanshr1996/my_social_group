import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/posts/models/post_key.dart';

@immutable
class ChatModel {
  final String sender;
  final String receiver;
  final String message;
  final String type;
  final DateTime createdAt;
  final List<String> fileName;
  final List<double> aspectRatio;
  final List<String> thumbnailStorageId;
  final List<String> originalFileStorageId;
  final List<String> thumbnailUrl;
  final List<String> fileUrl;

  ChatModel({required Map<String, dynamic> json})
      : sender = json[FirebaseFieldName.sender],
        receiver = json[FirebaseFieldName.receiver],
        message = json[FirebaseFieldName.message],
        type = json[FirebaseFieldName.type],
        createdAt = (json[FirebaseFieldName.createdAt] as Timestamp).toDate(),
        thumbnailUrl = json[PostKey.thumbnailUrl] == null
            ? []
            : (json[PostKey.thumbnailUrl] as List).map((item) => item as String).toList(),
        fileUrl =
            json[PostKey.fileUrl] == null ? [] : (json[PostKey.fileUrl] as List).map((item) => item as String).toList(),
        fileName = json[PostKey.fileName] == null
            ? []
            : (json[PostKey.fileName] as List).map((item) => item as String).toList(),
        aspectRatio = json[PostKey.aspectRatio] == null
            ? []
            : (json[PostKey.aspectRatio] as List).map((item) => item as double).toList(),
        thumbnailStorageId = json[PostKey.thumbnailStorageId] == null
            ? []
            : (json[PostKey.thumbnailStorageId] as List).map((item) => item as String).toList(),
        originalFileStorageId = json[PostKey.originalFileStorageId] == null
            ? []
            : (json[PostKey.originalFileStorageId] as List).map((item) => item as String).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModel &&
          runtimeType == other.runtimeType &&
          sender == other.sender &&
          receiver == other.receiver &&
          message == other.message &&
          type == other.type &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hashAll(
        [
          sender,
          receiver,
          message,
          type,
          createdAt,
        ],
      );
}
