import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/enums/date_sorting.dart';
import 'package:tekk_gram/state/comments/models/post_comments_request.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/state/posts/providers/specific_post_with_comment_provider.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/comment/compact_comment_column.dart';
import 'package:tekk_gram/views/components/like_button.dart';
import 'package:tekk_gram/views/components/post/post_like_comment_count.dart';
import 'package:tekk_gram/views/components/post/post_user_info.dart';
import 'package:tekk_gram/views/post_comments/post_comments_view.dart';

class PostListItemThumbnailView extends ConsumerWidget {
  final VoidCallback onTapped;
  final Post post;
  const PostListItemThumbnailView({super.key, required this.onTapped, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoModel = ref.watch(userInfoModelProvider(post.userId));
    final request = RequestForPostAndComments(
        postId: post.postId,
        limit: 3, // at most 3 comments
        sortByCreatedAt: true,
        dateSorting: DateSorting.oldestOnTop);
    final postWithComments = ref.watch(specificPostWithCommentsProvider(request));

    return userInfoModel.when(
      data: (userInfoModel) {
        return Column(
          children: [
            GestureDetector(
              onTap: onTapped,
              child: Container(
                width: Utilities.screenWidth(context),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minHeight: Utilities.screenHeight(context) * 0.25,
                        maxHeight: Utilities.screenHeight(context) * 0.6,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: [
                            post.thumbnailUrl == ""
                                ? const SizedBox()
                                : Image.network(
                                    post.thumbnailUrl,
                                    fit: BoxFit.cover,
                                  ),
                            Positioned(
                              top: -0.5,
                              child: PostUserInfo(
                                createdAt: post.createdAt,
                                displayName: userInfoModel.displayName,
                                imageUrl: userInfoModel.imageUrl == "" || userInfoModel.imageUrl == null
                                    ? ""
                                    : userInfoModel.imageUrl!,
                              ),
                            ),
                            Positioned(
                              bottom: -0.5,
                              child: PostLikeCommentCount(post: post),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            postWithComments.when(
              data: (postWithComments) {
                final postId = postWithComments.post.postId;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // like button if post allows liking it
                        if (postWithComments.post.allowsLikes) LikeButton(postId: postId),
                        // comment button if post allows commenting on it
                        if (postWithComments.post.allowsComments)
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.comment),
                            onPressed: () {
                              Utilities.openActivity(context, PostCommentsView(postId: postId));
                            },
                          ),
                      ],
                    ),
                    CompactCommentsColumn(comments: postWithComments.comments),
                    postWithComments.post.allowsLikes || postWithComments.post.allowsComments
                        ? const Divider(color: Colors.white54)
                        : const SizedBox.shrink(),
                  ],
                );
              },
              error: (error, stackTrace) {
                return const SizedBox.shrink();
              },
              loading: () {
                return const SizedBox.shrink();
              },
            )
          ],
        );
      },
      error: (error, stackTrace) {
        return const SizedBox();
      },
      loading: () {
        return const SizedBox();
      },
    );
  }
}
