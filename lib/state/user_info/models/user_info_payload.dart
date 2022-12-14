import 'dart:collection' show MapView;
import 'package:flutter/foundation.dart' show immutable;
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';

@immutable
class UserInfoPayload extends MapView<String, String> {
  UserInfoPayload({
    required UserId userId,
    required String? displayName,
    required String? email,
    required String? phone,
    required String? imageUrl,
  }) : super({
          FirebaseFieldName.userId: userId,
          FirebaseFieldName.displayName: displayName ?? "",
          FirebaseFieldName.email: email ?? "",
          FirebaseFieldName.phone: phone ?? "",
          FirebaseFieldName.imageUrl: imageUrl ?? "",
        });
}
