import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:tekk_gram/state/constants/firebase_field_name.dart';

@immutable
class ChatModel {
  final String sender;
  final String receiver;
  final String message;
  final String type;
  final DateTime createdAt;

  ChatModel({required Map<String, dynamic> json})
      : sender = json[FirebaseFieldName.sender],
        receiver = json[FirebaseFieldName.receiver],
        message = json[FirebaseFieldName.message],
        type = json[FirebaseFieldName.type],
        createdAt = (json[FirebaseFieldName.createdAt] as Timestamp).toDate();

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
