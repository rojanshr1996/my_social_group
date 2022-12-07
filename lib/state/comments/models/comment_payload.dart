import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/posts/typedefs/post_id.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';

@immutable
class CommentPayload extends MapView<String, dynamic> {
  CommentPayload({
    required UserId fromUserId,
    required PostId onPostId,
    required String comment,
    required String repliedUserName,
    required UserId repliedUserId,
  }) : super(
          {
            FirebaseFieldName.userId: fromUserId,
            FirebaseFieldName.postId: onPostId,
            FirebaseFieldName.comment: comment,
            FirebaseFieldName.repliedUser: repliedUserName,
            FirebaseFieldName.repliedUserId: repliedUserId,
            FirebaseFieldName.createdAt: FieldValue.serverTimestamp(),
          },
        );
}
