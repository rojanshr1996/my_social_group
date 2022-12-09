import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/posts/models/post_key.dart';

@immutable
class ChatPayload extends MapView<String, dynamic> {
  ChatPayload({
    required String sender,
    required String receiver,
    required String message,
    required String type,
    FieldValue? createdAt,
  }) : super(
          {
            FirebaseFieldName.sender: sender,
            FirebaseFieldName.receiver: receiver,
            FirebaseFieldName.message: message,
            FirebaseFieldName.type: type,
            PostKey.createdAt: createdAt,
          },
        );
}
