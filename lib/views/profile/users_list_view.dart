import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/chat/chat_message_screen.dart';
import 'package:tekk_gram/views/components/animations/empty_search_animation_view.dart';
import 'package:tekk_gram/views/components/animations/error_animation_view.dart';
import 'package:tekk_gram/views/components/animations/loading_animation_view.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/components/users/user_list_item.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/login/divider_with_margins.dart';

class UsersListView extends HookConsumerWidget {
  const UsersListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<Iterable<UserInfoModel>> usersList = ref.watch(usersListInfoProvider);
    final authUser = ref.read(userIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.users),
        centerTitle: false,
      ),
      body: usersList.when(
        data: (userList) {
          if (userList.isEmpty) {
            return const Center(child: EmptySearchAnimationView());
          }

          userList = userList.where((user) => user.userId != authUser).toList();

          return RemoveFocus(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                      child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final user = userList.elementAt(index);
                            return Column(
                              children: [
                                UserListItem(
                                    userData: user,
                                    onTap: () {
                                      Utilities.openActivity(context, ChatMessageScreen(userData: user));
                                    }),
                                const DividerWithMargins(margin: 10),
                              ],
                            );
                          },
                          childCount: userList.length,
                        ),
                      )
                    ],
                  ))
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) {
          return const ErrorAnimationView();
        },
        loading: () {
          return const LoadingAnimationView();
        },
      ),
    );
  }
}
