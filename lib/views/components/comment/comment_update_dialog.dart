import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/comments/models/comment.dart';
import 'package:tekk_gram/state/comments/providers/send_comment_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/extensions/dismiss_keyboard.dart';

class CommentUpdateDialog extends HookConsumerWidget {
  final Comment comment;
  const CommentUpdateDialog({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentController = useTextEditingController(text: comment.comment);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              textInputAction: TextInputAction.send,
              controller: commentController,
              onSubmitted: (comment) {},
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: Strings.writeYourCommentHere,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final isUpdated = await ref.read(sendCommentProvider.notifier).updateComment(
                      commentId: comment.id,
                      postId: comment.onPostId,
                      userId: comment.fromUserId,
                      comment: commentController.text.trim(),
                    );
                if (isUpdated) {
                  Utilities.closeActivity(context);
                  commentController.clear();
                  dismissKeyboard();
                }
              },
              child: SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(Strings.update),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
