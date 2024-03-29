import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/comments/models/comment.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/post_comments/edit_delete_bottom_sheet_widget.dart';
import 'package:tekk_gram/views/profile/post_user_profile_view.dart';

class CommentMessageView extends HookConsumerWidget {
  final Comment comment;
  final VoidCallback? onReply;
  final Function(int)? onSelected;
  const CommentMessageView({super.key, required this.comment, this.onReply, this.onSelected});

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
                    child: const SizedBox.shrink(),
                  ),
                  Flexible(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              !isOwnMessage
                                  ? Container(
                                      alignment: Alignment.bottomCenter,
                                      width: 16.0,
                                      height: 16.0,
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.darkColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: userInfoModel.imageUrl == ""
                                              ? Image.asset(appLogo)
                                              : Image.network(userInfoModel.imageUrl!),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              Text(
                                isOwnMessage ? authUserData.displayName : userInfoModel.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w500, color: AppColors.loginButtonTextColor),
                              ),
                              isOwnMessage
                                  ? Container(
                                      alignment: Alignment.bottomCenter,
                                      width: 16.0,
                                      height: 16.0,
                                      margin: const EdgeInsets.only(left: 6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.darkColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: userInfoModel.imageUrl == ""
                                              ? Image.asset(appLogo)
                                              : Image.network(userInfoModel.imageUrl!),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()
                            ],
                          ),
                        ),
                        comment.comment == ""
                            ? const SizedBox.shrink()
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Card(
                                      margin: const EdgeInsets.all(0),
                                      elevation: 0,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(15))),
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
                                                        recognizer: TapGestureRecognizer()
                                                          ..onTap = () {
                                                            Utilities.openActivity(context,
                                                                PostUserProfileView(userId: comment.repliedUserId));
                                                          },
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
                                  ),
                                  isOwnMessage
                                      ? EditDeleteBottomPopup(
                                          onSelected: (p0) {
                                            if (onSelected != null) {
                                              onSelected!(p0);
                                            }
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                size: 16,
                              ),
                            ),
                          ),
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
