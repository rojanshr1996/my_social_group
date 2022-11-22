import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/comments/models/comment_payload.dart';
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/image_upload/typedefs/is_loading.dart';
import 'package:tekk_gram/state/posts/typedefs/post_id.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';

class SendCommentNotifier extends StateNotifier<IsLoading> {
  SendCommentNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> sendComment({
    required UserId fromUserId,
    required PostId onPostId,
    required String comment,
  }) async {
    isLoading = true;
    final payload = CommentPayload(
      fromUserId: fromUserId,
      onPostId: onPostId,
      comment: comment,
    );
    try {
      await FirebaseFirestore.instance.collection(FirebaseCollectionName.comments).add(payload);
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> updateComment({
    required String commentId,
    required String comment,
    required String userId,
    required String postId,
  }) async {
    isLoading = true;

    try {
      log("Comment Id: $commentId");

      final commentData = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.comments)
          .where(FirebaseFieldName.postId, isEqualTo: postId)
          .get();

      final comments = commentData.docs.where((comment) => comment.id == commentId);

      if (comments.isNotEmpty) {
        await comments.first.reference.update({
          FirebaseFieldName.postId: postId,
          FirebaseFieldName.userId: userId,
          FirebaseFieldName.comment: comment,
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
