import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/posts/providers/all_posts_provider.dart';
import 'package:tekk_gram/state/toggle_view/toggle_posts_view_provider.dart';
import 'package:tekk_gram/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:tekk_gram/views/components/animations/error_animation_view.dart';
import 'package:tekk_gram/views/components/animations/loading_animation_view.dart';
import 'package:tekk_gram/views/components/post/post_list_view.dart';
import 'package:tekk_gram/views/components/post/posts_grid_view.dart';
import 'package:tekk_gram/views/constans/strings.dart';

class HomeView extends ConsumerWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(allPostsProvider);
    final toggleValue = ref.watch(togglePostsViewProvider);

    return RefreshIndicator(
      onRefresh: () {
        ref.refresh(allPostsProvider);
        return Future.delayed(
          const Duration(seconds: 1),
        );
      },
      child: posts.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyContentsWithTextAnimationView(
              text: Strings.noPostsAvailable,
            );
          } else {
            return toggleValue ? PostsGridView(posts: posts) : PostsListView(posts: posts);
          }
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
