import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/likes/providers/post_likes_count_provider.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/animations/small_error_animation_view.dart';
import 'package:tekk_gram/views/components/strings.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class PostLikeCommentCount extends ConsumerWidget {
  final Post post;

  const PostLikeCommentCount({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesCount = ref.watch(postLikesCountProvider(post.postId));

    return Container(
      width: Utilities.screenWidth(context),
      decoration: BoxDecoration(color: AppColors.darkColor.withOpacity(0.4)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: likesCount.when(
          data: (int likesCount) {
            final personOrPeople = likesCount == 1 ? Strings.person : Strings.people;
            final likesText = ' $personOrPeople ${Strings.likedThis}';
            return Row(
              children: [
                Icon(
                  post.fileType == FileType.image ? Icons.photo : Icons.video_camera_back,
                  size: 20,
                  color: Colors.white70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$likesCount",
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.loginButtonTextColor, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: likesText,
                          style: const TextStyle(fontSize: 10, color: AppColors.loginButtonTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
      ),
    );
  }
}
