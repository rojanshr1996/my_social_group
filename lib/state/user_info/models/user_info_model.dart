import 'dart:collection';

import 'package:flutter/foundation.dart' show immutable;
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';

@immutable
class UserInfoModel extends MapView<String, String?> {
  final UserId userId;
  final String displayName;
  final String? email;
  final String? phone;
  final String? imageUrl;

  UserInfoModel({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.imageUrl,
  }) : super(
          {
            FirebaseFieldName.userId: userId,
            FirebaseFieldName.displayName: displayName,
            FirebaseFieldName.email: email,
            FirebaseFieldName.phone: phone,
            FirebaseFieldName.imageUrl: imageUrl,
          },
        );

  UserInfoModel.fromJson(
    Map<String, dynamic> json, {
    required UserId userId,
  }) : this(
          userId: userId,
          displayName: json[FirebaseFieldName.displayName] ?? '',
          email: json[FirebaseFieldName.email],
          phone: json[FirebaseFieldName.phone],
          imageUrl: json[FirebaseFieldName.imageUrl],
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          displayName == other.displayName &&
          email == other.email &&
          phone == other.phone &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hashAll(
        [
          userId,
          displayName,
          email,
          phone,
          imageUrl,
        ],
      );
}
