import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/chat/models/chat_payload.dart';
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/image_upload/typedefs/is_loading.dart';

class ChatMessageNotifier extends StateNotifier<IsLoading> {
  ChatMessageNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> sendMessage({
    required String groupChatId,
    required String currentUserId,
    required String receiverId,
    required String message,
    String? type,
  }) async {
    isLoading = true;
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection(FirebaseCollectionName.chat)
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      ChatPayload messageChat = ChatPayload(
        sender: currentUserId,
        receiver: receiverId,
        createdAt: FieldValue.serverTimestamp(),
        message: message,
        type: type ?? "text",
      );
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          messageChat,
        );
      });
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
