import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/comments/models/comment.dart';
import 'package:tekk_gram/state/comments/models/post_comments_request.dart';
import 'package:tekk_gram/state/comments/providers/delete_comment_provider.dart';
import 'package:tekk_gram/state/comments/providers/post_comments_provider.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/views/components/animations/small_error_animation_view.dart';
import 'package:tekk_gram/views/components/comment/comment_update_dialog.dart';
import 'package:tekk_gram/views/components/strings.dart';
import 'package:tekk_gram/views/components/dialogs/alert_dialog_model.dart';
import 'package:tekk_gram/views/components/dialogs/delete_dialog.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class CommentTile extends HookConsumerWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = useState(
      RequestForPostAndComments(postId: comment.onPostId),
    );
    final userInfo = ref.watch(userInfoModelProvider(comment.fromUserId));
    return userInfo.when(data: (userInfoModel) {
      final currentUserId = ref.read(userIdProvider);

      return ListTile(
        title: Text(userInfoModel.displayName),
        subtitle: Text(comment.comment),
        trailing: currentUserId == comment.fromUserId
            ? SizedBox(
                width: 60,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return CommentUpdateDialog(comment: comment);
                          },
                        ).then((value) {
                          ref.refresh(postCommentsProvider(request.value));
                        });
                      },
                      child: const Icon(Icons.edit, size: 20),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        final shouldDeleteComment = await displayDeleteDialog(context);

                        if (shouldDeleteComment) {
                          await ref.read(deleteCommentProvider.notifier).deleteComment(commentId: comment.id);
                        }
                      },
                      child: Icon(
                        Icons.delete,
                        size: 20,
                        color: AppColors.loginButtonColor,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      );
    }, error: (error, stackTrace) {
      return const SmallErrorAnimationView();
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }

  Future<bool> displayDeleteDialog(BuildContext context) =>
      const DeleteDialog(titleOfObjectToDelete: Strings.comment).present(context).then((value) => value ?? false);
}
