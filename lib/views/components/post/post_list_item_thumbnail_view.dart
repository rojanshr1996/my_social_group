import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/enums/date_sorting.dart';
import 'package:tekk_gram/state/comments/models/post_comments_request.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/state/posts/providers/specific_post_with_comment_provider.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/comment/compact_comment_column.dart';
import 'package:tekk_gram/views/components/like_button.dart';
import 'package:tekk_gram/views/components/post/post_like_comment_count.dart';
import 'package:tekk_gram/views/components/post/post_user_info.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/post_comments/post_comments_view.dart';

class PostListItemThumbnailView extends HookConsumerWidget {
  final VoidCallback onTapped;
  final Post post;
  const PostListItemThumbnailView({super.key, required this.onTapped, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoModel = ref.watch(userInfoModelProvider(post.userId));
    final request = RequestForPostAndComments(
        postId: post.postId,
        limit: 3, // at most 3 comments
        sortByCreatedAt: true,
        dateSorting: DateSorting.oldestOnTop);
    final postWithComments = ref.watch(specificPostWithCommentsProvider(request));
    final currentPos = useState<int>(0);
    CarouselController controller = CarouselController();

    return userInfoModel.when(
      data: (userInfoModel) {
        return Column(
          children: [
            GestureDetector(
              onTap: onTapped,
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
                        minHeight: Utilities.screenHeight(context) * 0.25,
                        maxHeight: Utilities.screenHeight(context) * 0.55,
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            postWithComments.when(
              data: (postWithComments) {
                final postId = postWithComments.post.postId;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                              Utilities.openActivity(
                                  context,
                                  PostCommentsView(
                                    post: postWithComments.post,
                                  ));
                            },
                          ),
                        const Spacer(),
                        postWithComments.post.fileType == FileType.video
                            ? const SizedBox.shrink()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: post.fileUrl.map((url) {
                                  int index = post.fileUrl.indexOf(url);
                                  return Container(
                                    alignment: Alignment.bottomCenter,
                                    width: 10.0,
                                    height: 10.0,
                                    margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: currentPos.value == index
                                          ? AppColors.loginButtonColor
                                          : AppColors.loginButtonTextColor,
                                    ),
                                  );
                                }).toList(),
                              )
                      ],
                    ),
                    CompactCommentsColumn(comments: postWithComments.comments),
                    postWithComments.post.allowsLikes || postWithComments.post.allowsComments
                        ? const Divider(color: Colors.white54)
                        : const SizedBox.shrink(),
                  ],
                );
              },
              error: (error, stackTrace) {
                return const SizedBox.shrink();
              },
              loading: () {
                return const SizedBox.shrink();
              },
            )
          ],
        );
      },
      error: (error, stackTrace) {
        return const SizedBox();
      },
      loading: () {
        return const SizedBox();
      },
    );
  }
}
