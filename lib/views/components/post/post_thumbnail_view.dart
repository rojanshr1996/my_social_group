import 'package:flutter/material.dart';
import 'package:tekk_gram/state/posts/models/post.dart';

class PostThumbnailView extends StatelessWidget {
  final VoidCallback onTapped;
  final Post post;
  const PostThumbnailView({super.key, required this.onTapped, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Image.network(
        post.thumbnailUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}
