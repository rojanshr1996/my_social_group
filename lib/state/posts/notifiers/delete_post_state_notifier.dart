import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/image_upload/extensions/get_collection_name_from_file_type.dart';
import 'package:tekk_gram/state/image_upload/typedefs/is_loading.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/state/posts/typedefs/post_id.dart';

class DeletePostStateNotifier extends StateNotifier<IsLoading> {
  DeletePostStateNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> deletePost({required Post post}) async {
    try {
      isLoading = true;
      //delete the post thumbnail

      for (var element in post.thumbnailStorageId) {
        await FirebaseStorage.instance
            .ref()
            .child(post.userId)
            .child(FirebaseCollectionName.thumbnails)
            .child(element)
            .delete();
      }

      for (var element in post.originalFileStorageId) {
        // delete post original file
        await FirebaseStorage.instance
            .ref()
            .child(post.userId)
            .child(post.fileType.collectionName)
            .child(element)
            .delete();
      }

      // delete all comments for the post
      await _deleteAllDocuments(postId: post.postId, inCollection: FirebaseCollectionName.comments);

      // delete all likes for the post
      await _deleteAllDocuments(postId: post.postId, inCollection: FirebaseCollectionName.likes);

      // delete the post itself
      final postInCollection = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.posts)
          .where(FieldPath.documentId, isEqualTo: post.postId)
          .limit(1)
          .get();

      for (final post in postInCollection.docs) {
        await post.reference.delete();
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> _deleteAllDocuments({required PostId postId, required String inCollection}) {
    return FirebaseFirestore.instance.runTransaction(maxAttempts: 3, timeout: const Duration(seconds: 20),
        (transaction) async {
      final query = await FirebaseFirestore.instance
          .collection(inCollection)
          .where(FirebaseFieldName.postId, isEqualTo: postId)
          .get();

      for (final doc in query.docs) {
        transaction.delete(doc.reference);
      }
    });
  }
}
