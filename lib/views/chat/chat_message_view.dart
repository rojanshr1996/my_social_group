import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/chat/models/chat_model.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class ChatMessageView extends HookConsumerWidget {
  final ChatModel chatData;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const ChatMessageView({super.key, required this.chatData, this.onReply, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoModel = ref.watch(userInfoModelProvider(chatData.sender));
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
                        chatData.message == ""
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
                                        text: chatData.message,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color:
                                                isOwnMessage ? AppColors.loginButtonTextColor : AppColors.darkColor)),
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${DateFormat.yMMMd().format(chatData.createdAt)}, ${DateFormat.jm().format(chatData.createdAt)}",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.greyColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: isOwnMessage ? 0 : 1,
                    child: const SizedBox.shrink(),
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
