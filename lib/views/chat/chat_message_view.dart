import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/chat/models/chat_model.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class ChatMessageView extends HookConsumerWidget {
  final ChatModel chatData;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMessageTap;
  final int index;
  final int? currentPos;
  const ChatMessageView({
    super.key,
    required this.chatData,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onMessageTap,
    this.index = 0,
    this.currentPos,
  });

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
                            : GestureDetector(
                                onTap: onMessageTap,
                                child: Card(
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
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  isOwnMessage ? AppColors.loginButtonTextColor : AppColors.darkColor)),
                                    ),
                                  ),
                                ),
                              ),
                        chatData.thumbnailUrl.isEmpty
                            ? const SizedBox.shrink()
                            : GridView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                itemCount: chatData.thumbnailUrl.length,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                                itemBuilder: (BuildContext context, int index) {
                                  return chatData.thumbnailUrl[index] == ""
                                      ? const SizedBox()
                                      : InkWell(
                                          onTap: () {},
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Container(
                                              color: Theme.of(context).primaryColor,
                                              child: CachedNetworkImage(
                                                memCacheHeight: 200,
                                                filterQuality: FilterQuality.none,
                                                width: double.maxFinite,
                                                imageUrl: chatData.thumbnailUrl[index],
                                                placeholder: (context, url) => Center(
                                                  child: Image.asset(appLogo),
                                                ),
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url, error) => Center(
                                                    child:
                                                        Icon(Icons.broken_image, color: AppColors.greyColor, size: 20)),
                                              ),
                                            ),
                                          ),
                                        );
                                },
                              ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          height: currentPos == index ? 14 : 0,
                          curve: Curves.ease,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${DateFormat.yMMMd().format(chatData.createdAt)}, ${DateFormat.jm().format(chatData.createdAt)}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.greyColor),
                            ),
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
