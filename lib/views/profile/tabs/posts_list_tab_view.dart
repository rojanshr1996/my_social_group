import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/posts/providers/user_posts_provider.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:tekk_gram/views/components/animations/error_animation_view.dart';
import 'package:tekk_gram/views/components/animations/loading_animation_view.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/profile/user_post_list.dart';

class PostsListTabView extends ConsumerWidget {
  final UserInfoModel userData;

  const PostsListTabView({super.key, required this.userData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(userPostsProvider(userData.userId));
    final userInfoModel = ref.watch(userInfoModelProvider(userData.userId));

    return RefreshIndicator(
      onRefresh: () {
        ref.refresh(authUserPostsProvider);
        return Future.delayed(const Duration(seconds: 1));
      },
      child: userInfoModel.when(
        data: (userInfoModel) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: posts.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const EmptyContentsWithTextAnimationView(
                        text: Strings.youHaveNoPosts,
                      );
                    } else {
                      return UserPostList(posts: posts);
                    }
                  },
                  error: ((error, stackTrace) {
                    return const ErrorAnimationView();
                  }),
                  loading: () {
                    return const LoadingAnimationView();
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return const SizedBox.shrink();
        },
        loading: () {
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
