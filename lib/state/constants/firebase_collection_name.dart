import 'package:flutter/foundation.dart' show immutable;

@immutable
class FirebaseCollectionName {
  static const thumbnails = "thumbnails";
  static const comments = "comments";
  static const likes = "likes";
  static const posts = "posts";
  static const users = "users";
  static const chat = "chat";

  const FirebaseCollectionName._();
}
