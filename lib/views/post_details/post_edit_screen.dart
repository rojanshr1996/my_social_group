import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/enums/date_sorting.dart';
import 'package:tekk_gram/state/comments/models/post_comments_request.dart';
import 'package:tekk_gram/state/image_upload/helpers/image_picker_helper.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/image_upload/models/thumbnail_request.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/state/posts/providers/edit_post_provider.dart';
import 'package:tekk_gram/state/posts/providers/specific_post_with_comment_provider.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/camera_gallery_selection_widget.dart';
import 'package:tekk_gram/views/components/file_thumbnail_view.dart';
import 'package:tekk_gram/views/components/post/post_image_or_video_view.dart';
import 'package:tekk_gram/views/components/post/post_user_info.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';

class PostEditScreen extends StatefulHookConsumerWidget {
  final Post post;
  const PostEditScreen({super.key, required this.post});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends ConsumerState<PostEditScreen> {
  @override
  Widget build(BuildContext context) {
    final userInfoModel = ref.watch(userInfoModelProvider(widget.post.userId));
    final editTextController = useTextEditingController(text: widget.post.message);
    final isPostButtonEnabled = useState(true);

    useEffect(() {
      void listener() {
        isPostButtonEnabled.value = editTextController.text.isNotEmpty;
      }

      editTextController.addListener(listener);
      return () {
        editTextController.removeListener(listener);
      };
    }, [editTextController]);
    final request = RequestForPostAndComments(
        postId: widget.post.postId,
        limit: 3, // at most 3 comments
        sortByCreatedAt: true,
        dateSorting: DateSorting.oldestOnTop);
    final mediaFile = useState<List<File>>([]);
    final thumbnailRequest = useState<List<ThumbnailRequest>>([]);

    return RemoveFocus(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.editPost),
          actions: [
            IconButton(
              onPressed: isPostButtonEnabled.value
                  ? () async {
                      if (thumbnailRequest.value.isNotEmpty) {
                        final result = await ref.read(editPostProvider.notifier).editImagePost(
                              userId: widget.post.userId,
                              postId: widget.post.postId,
                              message: editTextController.text.trim(),
                              files: mediaFile.value,
                              fileType: thumbnailRequest.value.isEmpty
                                  ? FileType.image
                                  : thumbnailRequest.value.first.fileType,
                              originalFileStorageId: widget.post.originalFileStorageId,
                              thumbnailStorageId: widget.post.thumbnailStorageId,
                            );

                        log("RESULT: $result");
                        if (result != null) {
                          if (result && mounted) {
                            editTextController.clear();
                            ref.refresh(specificPostWithCommentsProvider(request));
                            Utilities.closeActivity(context);
                          }
                        }
                      } else {
                        final result = await ref.read(editPostProvider.notifier).editPost(
                              userId: widget.post.userId,
                              postId: widget.post.postId,
                              message: editTextController.text.trim(),
                              file: mediaFile.value.first,
                              fileType: thumbnailRequest.value.isEmpty
                                  ? FileType.image
                                  : thumbnailRequest.value.first.fileType,
                              originalFileStorageId: widget.post.originalFileStorageId.first,
                              thumbnailStorageId: widget.post.thumbnailStorageId.first,
                            );

                        log("RESULT: $result");

                        if (result && mounted) {
                          editTextController.clear();
                          ref.refresh(specificPostWithCommentsProvider(request));
                          Utilities.closeActivity(context);
                        }
                      }
                    }
                  : null,
              icon: const Icon(Icons.check),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              userInfoModel.when(
                data: (userInfoModel) {
                  return PostUserInfo(
                    createdAt: widget.post.createdAt == null ? "" : widget.post.createdAt.toString(),
                    displayName: userInfoModel.displayName,
                    imageUrl:
                        userInfoModel.imageUrl == "" || userInfoModel.imageUrl == null ? "" : userInfoModel.imageUrl!,
                  );
                },
                error: (error, stackTrace) {
                  return const SizedBox.shrink();
                },
                loading: () {
                  return const SizedBox.shrink();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: Strings.pleaseWriteYourMessageHere,
                  ),
                  autofocus: false,
                  maxLines: null,
                  controller: editTextController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Stack(
                  children: [
                    mediaFile.value.isEmpty
                        ? PostImageOrVideoView(
                            post: widget.post,
                          )
                        : CarouselSlider.builder(
                            itemCount: thumbnailRequest.value.length,
                            options: CarouselOptions(
                              aspectRatio: 0.9,
                              viewportFraction: 0.95,
                              enlargeCenterPage: true,
                              autoPlay: false,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) {},
                            ),
                            itemBuilder: (ctx, index, realIdx) {
                              return FileThumbnailView(
                                thumbnailRequest: thumbnailRequest.value[index],
                              );
                            },
                          ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.loginButtonColor,
                        ),
                        child: InkWell(
                          onTap: () async {
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
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: FaIcon(
                              FontAwesomeIcons.image,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.loginButtonColor,
                        ),
                        child: InkWell(
                          onTap: () async {
                            final image = await openCameraOption(context, isVideo: true);
                            if (image == null) {
                              return;
                            }
                            mediaFile.value = image;
                            if (mediaFile.value.isNotEmpty) {
                              mediaFile.value.map((file) {
                                thumbnailRequest.value.add(
                                  ThumbnailRequest(file: file, fileType: FileType.video),
                                );
                              }).toList();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: FaIcon(
                              FontAwesomeIcons.film,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  openCameraOption(BuildContext context, {bool isVideo = false}) {
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
                    if (isVideo) {
                      final videoFile = await ImagePickerHelper.pickVideoFromCamera();
                      if (!mounted) return;
                      Utilities.returnDataCloseActivity(context, [videoFile]);
                    } else {
                      final imageFile = await ImagePickerHelper.picImageFromCamera();
                      if (!mounted) return;
                      Utilities.returnDataCloseActivity(context, [imageFile]);
                    }
                  },
                  onGallaryTap: () async {
                    if (isVideo) {
                      final videoFile = await ImagePickerHelper.pickImageFromGallery();
                      if (!mounted) return;
                      Utilities.returnDataCloseActivity(context, [videoFile]);
                    } else {
                      // final imageFile = await ImagePickerHelper.pickImageFromGallery();
                      final imageFile = await ImagePickerHelper.pickMultiImageFromGallery();

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
