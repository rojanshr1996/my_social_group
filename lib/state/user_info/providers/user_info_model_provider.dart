import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';

final userInfoModelProvider = StreamProvider.family.autoDispose<UserInfoModel, UserId>(
  (ref, UserId userId) {
    final controller = StreamController<UserInfoModel>();

    final sub = FirebaseFirestore.instance
        .collection(
          FirebaseCollectionName.users,
        )
        .where(
          FirebaseFieldName.userId,
          isEqualTo: userId,
        )
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final json = doc.data();
        final userInfoModel = UserInfoModel.fromJson(
          json,
          userId: userId,
        );
        controller.add(userInfoModel);
      }
    });

    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  },
);

final usersListInfoProvider = StreamProvider.autoDispose<Iterable<UserInfoModel>>(
  (ref) {
    final controller = StreamController<Iterable<UserInfoModel>>();

    final sub = FirebaseFirestore.instance.collection(FirebaseCollectionName.users).snapshots().listen(
      (snapshots) {
        final users = snapshots.docs.map(
          (doc) => UserInfoModel.fromMap(json: doc.data()),
        );
        controller.sink.add(users);
      },
    );

    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  },
);
