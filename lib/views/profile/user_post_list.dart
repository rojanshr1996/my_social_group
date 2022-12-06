import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/post/post_list_item_thumbnail_view.dart';
import 'package:tekk_gram/views/post_details/post_details_view.dart';

class UserPostList extends HookConsumerWidget {
  final Iterable<Post> posts;
  const UserPostList({super.key, required this.posts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
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
    );
  }
}
