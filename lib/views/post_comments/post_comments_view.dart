import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/comments/models/post_comments_request.dart';
import 'package:tekk_gram/state/comments/providers/post_comments_provider.dart';
import 'package:tekk_gram/state/comments/providers/send_comment_provider.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:tekk_gram/views/components/animations/error_animation_view.dart';
import 'package:tekk_gram/views/components/animations/loading_animation_view.dart';
import 'package:tekk_gram/views/components/comment/comment_tile.dart';
import 'package:tekk_gram/views/components/post/post_like_comment_count.dart';
import 'package:tekk_gram/views/components/post/post_user_info.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/extensions/dismiss_keyboard.dart';

class PostCommentsView extends HookConsumerWidget {
  final Post post;

  const PostCommentsView({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Related to post
    final currentPos = useState<int>(0);
    final userInfoModel = ref.watch(userInfoModelProvider(post.userId));
    CarouselController controller = CarouselController();

    final commentController = useTextEditingController();
    final autofocus = useState<bool>(false);
    final hasText = useState(false);
    final request = useState(
      RequestForPostAndComments(postId: post.postId),
    );
    final comments = ref.watch(postCommentsProvider(request.value));

    // enable Post button when text is entered in the textfield
    useEffect(
      () {
        commentController.addListener(() {
          hasText.value = commentController.text.isNotEmpty;
        });
        return () {};
      },
      [commentController],
    );

    return RemoveFocus(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.comments),
        ),
        body: SafeArea(
          child: NestedScrollView(
            // controller: _sc,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      userInfoModel.when(
                        data: (userInfoModel) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                                      minHeight: Utilities.screenHeight(context) * 0.3,
                                      maxHeight: Utilities.screenHeight(context) * 0.4,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Stack(
                                        fit: StackFit.passthrough,
                                        children: [
                                          post.thumbnailUrl.isEmpty
                                              ? const SizedBox()
                                              : SizedBox(
                                                  child: CarouselSlider.builder(
                                                    carouselController: controller,
                                                    itemCount: post.thumbnailUrl.length,
                                                    options: CarouselOptions(
                                                      aspectRatio: 0.8,
                                                      viewportFraction: 1,
                                                      enlargeCenterPage: true,
                                                      autoPlay: false,
                                                      enableInfiniteScroll: false,
                                                      onPageChanged: (index, reason) {
                                                        currentPos.value = index;
                                                      },
                                                    ),
                                                    itemBuilder: (ctx, index, realIdx) {
                                                      return Image.network(
                                                        post.thumbnailUrl[index],
                                                        fit: BoxFit.cover,
                                                        width: Utilities.screenWidth(context),
                                                      );
                                                    },
                                                  ),
                                                ),
                                          Positioned(
                                            top: -0.5,
                                            child: PostUserInfo(
                                              createdAt: post.createdAt == null ? "" : post.createdAt.toString(),
                                              displayName: userInfoModel.displayName,
                                              imageUrl: userInfoModel.imageUrl == "" || userInfoModel.imageUrl == null
                                                  ? ""
                                                  : userInfoModel.imageUrl!,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -0.5,
                                            child: PostLikeCommentCount(post: post),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 16,
                                            child: post.fileType == FileType.video
                                                ? const SizedBox.shrink()
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: post.fileUrl.map((url) {
                                                      int index = post.fileUrl.indexOf(url);
                                                      return Container(
                                                        alignment: Alignment.bottomCenter,
                                                        width: 10.0,
                                                        height: 10.0,
                                                        margin:
                                                            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: currentPos.value == index
                                                              ? AppColors.loginButtonColor
                                                              : AppColors.loginButtonTextColor,
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        error: (error, stackTrace) {
                          return const SizedBox();
                        },
                        loading: () {
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: SizedBox(
              height: Utilities.screenHeight(context),
              width: Utilities.screenWidth(context),
              child: Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      "Comments",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: comments.when(
                      data: (comments) {
                        if (comments.isEmpty) {
                          return const SingleChildScrollView(
                            child: EmptyContentsWithTextAnimationView(
                              text: Strings.noCommentsYet,
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () {
                            ref.refresh(
                              postCommentsProvider(request.value),
                            );
                            return Future.delayed(const Duration(seconds: 1));
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments.elementAt(index);
                              return CommentTile(
                                comment: comment,
                                onReply: (comment) {
                                  final user = ref.read(userInfoModelProvider(comment.fromUserId));
                                  user.whenData((value) {
                                    commentController.text = "@${value.displayName.replaceAll(" ", "")}";
                                    autofocus.value = true;
                                  });
                                },
                              );
                            },
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
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                textInputAction: TextInputAction.send,
                                controller: commentController,
                                autofocus: autofocus.value,
                                onSubmitted: (comment) {
                                  if (comment.isNotEmpty) {
                                    _submitCommentWithController(
                                      commentController,
                                      ref,
                                    );
                                  }
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: Strings.writeYourCommentHere,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: hasText.value
                                  ? () {
                                      _submitCommentWithController(
                                        commentController,
                                        ref,
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
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

  Future<void> _submitCommentWithController(
    TextEditingController controller,
    WidgetRef ref,
  ) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) {
      return;
    }
    final isSent = await ref
        .read(
          sendCommentProvider.notifier,
        )
        .sendComment(
          fromUserId: userId,
          onPostId: post.postId,
          comment: controller.text,
        );
    if (isSent) {
      controller.clear();
      dismissKeyboard();
    }
  }
}
