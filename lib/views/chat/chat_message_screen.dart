import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/chat/providers/chat_message_provider.dart';
import 'package:tekk_gram/state/chat/providers/send_chat_message_provider.dart';
import 'package:tekk_gram/state/image_upload/helpers/image_picker_helper.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/image_upload/models/thumbnail_request.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/chat/chat_message_view.dart';
import 'package:tekk_gram/views/components/animations/empty_contents_animation_view.dart';
import 'package:tekk_gram/views/components/animations/error_animation_view.dart';
import 'package:tekk_gram/views/components/animations/loading_animation_view.dart';
import 'package:tekk_gram/views/components/camera_gallery_selection_widget.dart';
import 'package:tekk_gram/views/components/dialogs/alert_dialog_model.dart';
import 'package:tekk_gram/views/components/dialogs/delete_dialog.dart';
import 'package:tekk_gram/views/components/file_thumbnail_view.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/components/strings.dart' as str;
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';

class ChatMessageScreen extends StatefulHookConsumerWidget {
  final UserInfoModel userData;

  const ChatMessageScreen({super.key, required this.userData});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends ConsumerState<ChatMessageScreen> {
  @override
  Widget build(BuildContext context) {
    String groupChatId = "";
    final autofocus = useState<bool>(false);
    final messageController = useTextEditingController();
    final hasText = useState(false);
    final currentPos = useState<int?>(null);
    final mediaFile = useState<List<File>>([]);
    final thumbnailRequest = useState<List<ThumbnailRequest>>([]);

    final sc = useScrollController();

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
      if (authUserModel.compareTo(widget.userData.userId) > 0) {
        groupChatId = '$authUserModel-${widget.userData.userId}';
      } else {
        groupChatId = '${widget.userData.userId}-$authUserModel';
      }
    }
    log("GROUP CHAT ID FOR THIS GROUP: $groupChatId");
    final chatMessageList = ref.watch(chatMessageProvider(groupChatId));
    // final userInfoModel = ref.watch(userInfoModelProvider(widget.userData.userId));

    return RemoveFocus(
      onTap: () {
        FocusScope.of(context).unfocus();
        currentPos.value = null;
      },
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
                            // return Container();
                            return const SingleChildScrollView(
                              child: EmptyContentsAnimationView(),
                            );
                          }
                          return Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.darkColor.withAlpha(50),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: CustomScrollView(
                                    controller: sc,
                                    reverse: true,
                                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                    slivers: <Widget>[
                                      SliverPadding(
                                        padding: const EdgeInsets.all(8),
                                        sliver: SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              final chatMessage = chatMessages.elementAt(index);
                                              return ChatMessageView(
                                                chatData: chatMessage,
                                                onMessageTap: () {
                                                  currentPos.value = index;
                                                },
                                                index: index,
                                                currentPos: currentPos.value,
                                              );
                                            },
                                            childCount: chatMessages.length,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: thumbnailRequest.value.isEmpty ? 0 : 16),
                              thumbnailRequest.value.isEmpty
                                  ? const SizedBox.shrink()
                                  : Stack(
                                      children: [
                                        Container(
                                          height: 110,
                                          decoration: BoxDecoration(
                                            color: AppColors.darkColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          width: Utilities.screenWidth(context),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: thumbnailRequest.value.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 15.0),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: FileThumbnailView(
                                                        thumbnailRequest: thumbnailRequest.value[index],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 2,
                                          top: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              thumbnailRequest.value.clear();
                                              mediaFile.value.clear();
                                              setState(() {});
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  color: AppColors.loginButtonColor,
                                                  borderRadius: BorderRadius.circular(10)),
                                              child: const Icon(
                                                Icons.close,
                                                color: AppColors.loginButtonTextColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                            ],
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
                                onSubmitted: (message) async {
                                  if (message.isNotEmpty) {
                                    final isSent = await _submitMessageWithController(
                                      controller: messageController,
                                      ref: ref,
                                      groupChatId: groupChatId,
                                      files: mediaFile.value,
                                    );

                                    if (isSent) {
                                      messageController.clear();
                                      mediaFile.value.clear();
                                      thumbnailRequest.value.clear();
                                      if (!mounted) return;
                                      FocusScope.of(context).unfocus();
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: Strings.writeYourMessageHere,
                                    suffixIcon: IconButton(
                                        onPressed: () async {
                                          final image = await openCameraOption(context);
                                          if (image == null) {
                                            return;
                                          }
                                          mediaFile.value = image;
                                          if (mediaFile.value.isNotEmpty) {
                                            mediaFile.value.map((file) {
                                              thumbnailRequest.value.add(
                                                ThumbnailRequest(file: file, fileType: FileType.image),
                                              );
                                            }).toList();
                                          }
                                        },
                                        icon: const FaIcon(
                                          FontAwesomeIcons.image,
                                          size: 20,
                                        ))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: FaIcon(
                              Icons.send,
                              color: AppColors.loginButtonColor,
                            ),
                            onPressed: hasText.value
                                ? () async {
                                    final isSent = await _submitMessageWithController(
                                      controller: messageController,
                                      ref: ref,
                                      groupChatId: groupChatId,
                                      files: mediaFile.value,
                                    );

                                    if (isSent) {
                                      messageController.clear();
                                      mediaFile.value.clear();
                                      thumbnailRequest.value.clear();
                                      if (!mounted) return;
                                      FocusScope.of(context).unfocus();
                                    }
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

  Future<bool> _submitMessageWithController({
    required TextEditingController controller,
    required WidgetRef ref,
    required String groupChatId,
    List<File> files = const [],
  }) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) {
      return false;
    }

    final isSent = await ref.read(sendChatMessageProvider.notifier).sendMessage(
          groupChatId: groupChatId,
          currentUserId: userId,
          receiverId: widget.userData.userId,
          message: controller.text.trim(),
          files: files,
        );
    return isSent;
  }

  openCameraOption(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CameraGallerySelectionWidget(
                  onCameraTap: () async {
                    final imageFile = await ImagePickerHelper.picImageFromCamera();
                    if (imageFile != null) {}
                  },
                  onGallaryTap: () async {
                    final imageFile = await ImagePickerHelper.pickMultiImageFromGallery();
                    log("IMAGE: $imageFile");
                    if (imageFile.isNotEmpty) {
                      if (!mounted) return;
                      Utilities.returnDataCloseActivity(context, imageFile);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
