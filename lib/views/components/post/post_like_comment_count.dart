import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/likes/providers/post_likes_count_provider.dart';
import 'package:tekk_gram/state/posts/typedefs/post_id.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/animations/small_error_animation_view.dart';
import 'package:tekk_gram/views/components/strings.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class PostLikeCommentCount extends ConsumerWidget {
  final PostId postId;

  const PostLikeCommentCount({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesCount = ref.watch(postLikesCountProvider(postId));

    return Container(
      width: Utilities.screenWidth(context),
      decoration: BoxDecoration(color: AppColors.darkColor.withOpacity(0.4)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            likesCount.when(
              data: (int likesCount) {
                final personOrPeople = likesCount == 1 ? Strings.person : Strings.people;
                final likesText = '$likesCount $personOrPeople ${Strings.likedThis}';
                return Text(
                  likesText,
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                );
              },
              error: (error, stackTrace) {
                return const SmallErrorAnimationView();
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
