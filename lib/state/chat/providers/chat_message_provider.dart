import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/chat/models/chat_model.dart';
import 'package:tekk_gram/state/chat/typedefs/chat_gorup_id.dart';
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/constants/firebase_field_name.dart';

final chatMessageProvider =
    StreamProvider.family.autoDispose<Iterable<ChatModel>, ChatGroupId>((ref, ChatGroupId groupId) {
  final controller = StreamController<Iterable<ChatModel>>();

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.chat)
      .doc(groupId)
      .collection(groupId)
      .orderBy(FirebaseFieldName.createdAt, descending: true)
      .snapshots()
      .listen((snapshot) {
    final chatMessages = snapshot.docs.where((doc) => !doc.metadata.hasPendingWrites).map(
          (document) => ChatModel(json: document.data()),
        );
    controller.sink.add(chatMessages);
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});
