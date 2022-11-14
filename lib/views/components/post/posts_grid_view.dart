import 'package:flutter/material.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/post/post_thumbnail_view.dart';
import 'package:tekk_gram/views/post_details/post_details_view.dart';

class PostsGridView extends StatelessWidget {
  final Iterable<Post> posts;
  const PostsGridView({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
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
    );
  }
}
