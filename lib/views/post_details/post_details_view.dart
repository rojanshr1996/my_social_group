import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tekk_gram/enums/date_sorting.dart';
import 'package:tekk_gram/state/comments/models/post_comments_request.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/state/posts/providers/can_current_user_delete_post_provider.dart';
import 'package:tekk_gram/state/posts/providers/delete_post_provider.dart';
import 'package:tekk_gram/state/posts/providers/specific_post_with_comment_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/animations/error_animation_view.dart';
import 'package:tekk_gram/views/components/animations/loading_animation_view.dart';
import 'package:tekk_gram/views/components/animations/small_error_animation_view.dart';
import 'package:tekk_gram/views/components/comment/compact_comment_column.dart';
import 'package:tekk_gram/views/components/dialogs/alert_dialog_model.dart';
import 'package:tekk_gram/views/components/dialogs/delete_dialog.dart';
import 'package:tekk_gram/views/components/like_button.dart';
import 'package:tekk_gram/views/components/likes_count_view.dart';
import 'package:tekk_gram/views/components/post/post_display_name_and_message.dart';
import 'package:tekk_gram/views/components/post/post_image_or_video_view.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/post_comments/post_comments_view.dart';
import 'package:tekk_gram/views/post_details/post_edit_screen.dart';

class PostDetailsView extends ConsumerStatefulWidget {
  final Post post;
  const PostDetailsView({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostDetailsViewState();
}

class _PostDetailsViewState extends ConsumerState<PostDetailsView> {
  @override
  Widget build(BuildContext context) {
    final request = RequestForPostAndComments(
        postId: widget.post.postId,
        limit: 3, // at most 3 comments
        sortByCreatedAt: true,
        dateSorting: DateSorting.oldestOnTop);

    // get the actual post together with its comments
    final postWithComments = ref.watch(specificPostWithCommentsProvider(request));

    // can we delete this post?
    final canDeletePost = ref.watch(canCurrentUserDeletePostProvider(widget.post));

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.postDetails),
        centerTitle: false,
        actions: [
          // share button is always present
          postWithComments.when(
            data: (postWithComments) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () {
                      final url = postWithComments.post.fileUrl.first;
                      Share.share(url, subject: Strings.checkOutThisPost);
                    },
                  ),
                  // delete button or no delete button if user cannot delete this post
                  if (canDeletePost.value ?? false)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                          ),
                          onPressed: () async {
                            Utilities.openActivity(context, PostEditScreen(post: postWithComments.post));
                            // delete the post now
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: AppColors.loginButtonColor,
                            size: 20,
                          ),
                          onPressed: () async {
                            final shouldDeletePost = await const DeleteDialog(titleOfObjectToDelete: Strings.post)
                                .present(context)
                                .then((shouldDelete) => shouldDelete ?? false);
                            if (shouldDeletePost) {
                              await ref.read(deletePostProvider.notifier).deletePost(post: widget.post);
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                            // delete the post now
                          },
                        ),
                      ],
                    )
                ],
              );
            },
            error: (error, stackTrace) {
              return const SmallErrorAnimationView();
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
      body: postWithComments.when(
        data: (postWithComments) {
          final postId = postWithComments.post.postId;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // post details (shows divider at bottom)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: PostDisplayNameAndMessageView(post: postWithComments.post),
                ),
                PostImageOrVideoView(post: postWithComments.post),
                // like and comment buttons
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
                          Utilities.openActivity(context, PostCommentsView(post: postWithComments.post));
                        },
                      ),
                  ],
                ),

                // PostDateView(dateTime: postWithComments.post.createdAt!),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Divider(color: Colors.white70),
                ),
                // comments
                CompactCommentsColumn(comments: postWithComments.comments),
                // display like count
                if (postWithComments.post.allowsLikes)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        LikesCountView(postId: postId),
                      ],
                    ),
                  ),
                // add spacing to bottom of screen
                const SizedBox(height: 80),
              ],
            ),
          );
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
