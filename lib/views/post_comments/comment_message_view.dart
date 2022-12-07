import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/comments/models/comment.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class CommentMessageView extends HookConsumerWidget {
  final Comment comment;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const CommentMessageView({super.key, required this.comment, this.onReply, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoModel = ref.watch(userInfoModelProvider(comment.fromUserId));
    final authUser = ref.read(userIdProvider);

    return userInfoModel.when(
      data: (userInfoModel) {
        bool isOwnMessage = authUser == userInfoModel.userId ? true : false;
        final authUserData = ref.watch(userInfoModelProvider(authUser ?? ""));

        return authUserData.when(
          data: (authUserData) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Flexible(
                    flex: isOwnMessage ? 1 : 0,
                    child: isOwnMessage
                        ? Row(
                            children: [
                              GestureDetector(
                                onTap: onDelete,
                                child: const Icon(
                                  Icons.delete,
                                  color: AppColors.loginButtonTextColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: onEdit,
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: FaIcon(
                                    FontAwesomeIcons.pencil,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            isOwnMessage ? authUserData.displayName : userInfoModel.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500, color: AppColors.loginButtonTextColor),
                          ),
                        ),
                        comment.comment == ""
                            ? const SizedBox.shrink()
                            : Card(
                                elevation: 0,
                                shape:
                                    const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                color: isOwnMessage ? AppColors.loginButtonColor : AppColors.greyColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text.rich(
                                    TextSpan(
                                        text: '',
                                        children: comment.comment.split(' ').map((w) {
                                          return w.startsWith('@') && w.length > 1
                                              ? TextSpan(
                                                  text: comment.repliedUserName,
                                                  // text: w.substring(0),
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        color: isOwnMessage
                                                            ? AppColors.loginButtonTextColor
                                                            : AppColors.darkColor,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                  // recognizer: TapGestureRecognizer()..onTap = () => showProfile(w),
                                                )
                                              : TextSpan(
                                                  text: ' $w',
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        color: isOwnMessage
                                                            ? AppColors.loginButtonTextColor
                                                            : AppColors.darkColor,
                                                      ),
                                                );
                                        }).toList()),
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${DateFormat.yMMMd().format(comment.createdAt)}, ${DateFormat.jm().format(comment.createdAt)}",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.greyColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: isOwnMessage ? 0 : 1,
                    child: isOwnMessage
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onTap: onReply,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: FaIcon(
                                FontAwesomeIcons.reply,
                                size: 18,
                              ),
                            )),
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) {
            return const SizedBox.shrink();
          },
          loading: () {
            return const SizedBox.shrink();
          },
        );
      },
      error: (error, stackTrace) {
        return const SizedBox.shrink();
      },
      loading: () {
        return const SizedBox.shrink();
      },
    );
  }
}
