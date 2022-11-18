import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/home/providers/bottom_nav_bar_scroll_visibility_provider.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/post/post_list_item_thumbnail_view.dart';
import 'package:tekk_gram/views/post_details/post_details_view.dart';

class PostsListView extends HookConsumerWidget {
  final Iterable<Post> posts;
  const PostsListView({super.key, required this.posts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    // useEffect(
    //   () {
    //     scrollController.addListener(() {
    //       if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
    //         log("SCROLLING FORWARD: ....");
    //       }
    //       if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
    //         log("SCROLLING BACKWARD: ....");
    //       }
    //     });
    //     return scrollController.dispose;
    //   },
    //   [scrollController],
    // );
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
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PostListItemThumbnailView(
                      post: post,
                      onTapped: () {
                        // Navigate to post detail view
                        Utilities.openActivity(context, PostDetailsView(post: post));
                      },
                    ),
                  );
                },
                childCount: posts.length,
              ),
            ),
          ),
        ],
      ),
    );

    // ListView.builder(
    //   padding: const EdgeInsets.all(8),
    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 3,
    //     mainAxisSpacing: 8,
    //     crossAxisSpacing: 8,
    //   ),
    //   itemCount: posts.length,
    //   itemBuilder: (context, index) {
    //     final post = posts.elementAt(index);
    //     return PostThumbnailView(
    //       post: post,
    //       onTapped: () {
    //         // Navigate to post detail view

    //         Utilities.openActivity(context, PostDetailsView(post: post));
    //       },
    //     );
    //   },
    // );
  }
}
