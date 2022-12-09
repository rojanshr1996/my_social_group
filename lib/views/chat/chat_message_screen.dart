import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/chat/providers/chat_message_provider.dart';
import 'package:tekk_gram/state/chat/providers/send_chat_message_provider.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/chat/chat_message_view.dart';
import 'package:tekk_gram/views/components/animations/error_animation_view.dart';
import 'package:tekk_gram/views/components/animations/loading_animation_view.dart';
import 'package:tekk_gram/views/components/dialogs/alert_dialog_model.dart';
import 'package:tekk_gram/views/components/dialogs/delete_dialog.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/components/strings.dart' as str;
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/extensions/dismiss_keyboard.dart';

class ChatMessageScreen extends HookConsumerWidget {
  final UserInfoModel userData;

  const ChatMessageScreen({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String groupChatId = "";
    final autofocus = useState<bool>(false);
    final messageController = useTextEditingController();
    final hasText = useState(false);
    useEffect(
      () {
        messageController.addListener(() {
          hasText.value = messageController.text.isNotEmpty;
        });
        return () {};
      },
      [messageController],
    );
    // Related to post
    final authUserModel = ref.read(userIdProvider);
    if (authUserModel != null) {
      if (authUserModel.compareTo(userData.userId) > 0) {
        groupChatId = '$authUserModel-${userData.userId}';
      } else {
        groupChatId = '${userData.userId}-$authUserModel';
      }
    }
    log("GROUP CHAT ID FOR THIS GROUP: $groupChatId");
    final chatMessageList = ref.watch(chatMessageProvider(groupChatId));
    final userInfoModel = ref.watch(userInfoModelProvider(userData.userId));

    return RemoveFocus(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.chat),
        ),
        body: SafeArea(
          child: NestedScrollView(
            // controller: _sc,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[];
            },
            body: SizedBox(
              height: Utilities.screenHeight(context),
              width: Utilities.screenWidth(context),
              child: Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: chatMessageList.when(
                        data: (chatMessages) {
                          log("CHAT MESSAGES: $chatMessageList");

                          if (chatMessages.isEmpty) {
                            return Container();
                            // return const SingleChildScrollView(
                            //   child: EmptyContentsAnimationView(),
                            // );
                          }
                          return Container(
                            decoration: BoxDecoration(
                                color: AppColors.darkColor.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                            child: CustomScrollView(
                              reverse: true,
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              slivers: <Widget>[
                                SliverPadding(
                                  padding: const EdgeInsets.all(8),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final chatMessage = chatMessages.elementAt(index);
                                        return ChatMessageView(chatData: chatMessage);
                                      },
                                      childCount: chatMessages.length,
                                    ),
                                  ),
                                ),
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
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 120),
                              child: TextField(
                                textInputAction: TextInputAction.send,
                                controller: messageController,
                                autofocus: autofocus.value,
                                maxLines: null,
                                textCapitalization: TextCapitalization.sentences,
                                onSubmitted: (message) {
                                  if (message.isNotEmpty) {
                                    _submitMessageWithController(
                                      controller: messageController,
                                      ref: ref,
                                      groupChatId: groupChatId,
                                    );
                                  }
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: Strings.writeYourMessageHere,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: hasText.value
                                ? () {
                                    _submitMessageWithController(
                                      controller: messageController,
                                      ref: ref,
                                      groupChatId: groupChatId,
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> displayDeleteDialog(BuildContext context) =>
      const DeleteDialog(titleOfObjectToDelete: str.Strings.comment).present(context).then((value) => value ?? false);

  Future<void> _submitMessageWithController({
    required TextEditingController controller,
    required WidgetRef ref,
    required String groupChatId,
  }) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) {
      return;
    }

    final isSent = await ref.read(sendChatMessageProvider.notifier).sendMessage(
          groupChatId: groupChatId,
          currentUserId: userId,
          receiverId: userData.userId,
          message: controller.text.trim(),
        );

    if (isSent) {
      controller.clear();
      dismissKeyboard();
    }
  }
}
