import 'package:flutter/foundation.dart' show immutable;

@immutable
class FirebaseFieldName {
  static const id = "id";
  static const userId = "uid";
  static const postId = "pos_id";
  static const comment = "comment";
  static const createdAt = "created_at";
  static const date = "date";
  static const displayName = "display_name";
  static const email = "email";

  static const repliedUser = "replied_user";
  static const repliedUserId = "replied_user_id";

  static const phone = "phone";
  static const imageUrl = "imageUrl";

  const FirebaseFieldName._();
}
