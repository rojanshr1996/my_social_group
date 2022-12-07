import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/animations/small_error_animation_view.dart';
import 'package:tekk_gram/views/components/post/post_user_info.dart';
import 'package:tekk_gram/views/components/rich_two_parts_text.dart';
import 'package:tekk_gram/views/profile/post_user_profile_view.dart';
import 'package:tekk_gram/views/profile/user_profile_view.dart';

class PostDisplayNameAndMessageView extends ConsumerWidget {
  final Post post;
  const PostDisplayNameAndMessageView({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoModel = ref.watch(userInfoModelProvider(post.userId));

    return userInfoModel.when(
      data: (userInfoModel) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                final authUser = ref.read(userIdProvider);
                if (post.userId == authUser) {
                  Utilities.openActivity(context, const UserProfileView());
                } else {
                  Utilities.openActivity(context, PostUserProfileView(userId: post.userId));
                }
              },
              child: PostUserInfo(
                postData: post,
                removeDecoration: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: RichTwoPartsText(
                leftPart: "",
                rightPart: post.message,
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
    );
  }
}
