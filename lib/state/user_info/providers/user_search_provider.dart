import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/posts/typedefs/search_term.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';

final userSearchProvider = StreamProvider.family.autoDispose<Iterable<UserInfoModel>, SearchTerm>(
  (ref, SearchTerm searchTerm) {
    final controller = StreamController<Iterable<UserInfoModel>>();

    final sub = FirebaseFirestore.instance.collection(FirebaseCollectionName.users).snapshots().listen(
      (snapshots) {
        final users = snapshots.docs
            .map(
              (doc) => UserInfoModel.fromMap(json: doc.data()),
            )
            .where(
              (user) => user.displayName.toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  ),
            );

        log("THIS USER LIST: ${users.length}");
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
