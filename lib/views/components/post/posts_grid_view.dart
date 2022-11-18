import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/home/providers/bottom_nav_bar_scroll_visibility_provider.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/post/post_thumbnail_view.dart';
import 'package:tekk_gram/views/post_details/post_details_view.dart';

class PostsGridView extends HookConsumerWidget {
  final Iterable<Post> posts;
  const PostsGridView({super.key, required this.posts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
          Future.delayed(const Duration(milliseconds: 150),
              () => ref.read(bottomNavBarScrollVisibilityProvider.notifier).showBottomNavBar(showBottomNavBar: false));
        } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
          ref.read(bottomNavBarScrollVisibilityProvider.notifier).showBottomNavBar(showBottomNavBar: true);
        }
        return true;
      },
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts.elementAt(index);
          return PostThumbnailView(
            post: post,
            onTapped: () {
              // Navigate to post detail view

              Utilities.openActivity(context, PostDetailsView(post: post));
            },
          );
        },
      ),
    );
  }
}
