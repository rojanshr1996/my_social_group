import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/image_upload/models/thumbnail_request.dart';
import 'package:tekk_gram/state/image_upload/providers/image_uploader_provider.dart';
import 'package:tekk_gram/state/post_settings/models/post_settings.dart';
import 'package:tekk_gram/state/post_settings/providers/post_settings_provider.dart';
import 'package:tekk_gram/views/components/file_thumbnail_view.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/constans/strings.dart';

class CreateNewPostListView extends StatefulHookConsumerWidget {
  final List<File> fileToPost;
  final FileType fileType;

  const CreateNewPostListView({
    Key? key,
    required this.fileToPost,
    required this.fileType,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateNewPostViewState();
}

class _CreateNewPostViewState extends ConsumerState<CreateNewPostListView> {
  @override
  Widget build(BuildContext context) {
    // final thumbnailRequest = ThumbnailRequest(
    //   file: widget.fileToPost,
    //   fileType: widget.fileType,
    // );
    List<ThumbnailRequest> thumbnailRequestList = [];

    widget.fileToPost.map((file) {
      thumbnailRequestList.add(
        ThumbnailRequest(
          file: file,
          fileType: widget.fileType,
        ),
      );
    }).toList();

    final postSettings = ref.watch(postSettingsProvider);
    final postController = useTextEditingController();
    final isPostButtonEnabled = useState(false);
    useEffect(() {
      void listener() {
        isPostButtonEnabled.value = postController.text.isNotEmpty;
      }

      postController.addListener(listener);
      return () {
        postController.removeListener(listener);
      };
    }, [postController]);
    return RemoveFocus(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            Strings.createNewPost,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: isPostButtonEnabled.value
                  ? () async {
                      // get the user id first
                      final userId = ref.read(userIdProvider);
                      if (userId == null) {
                        return;
                      }

                      final message = postController.text;
                      FocusManager.instance.primaryFocus?.unfocus();
                      final isUploaded = await ref.read(imageUploadProvider.notifier).uploadMultipleImageFiles(
                            files: widget.fileToPost,
                            fileType: widget.fileType,
                            message: message,
                            postSettings: postSettings,
                            userId: userId,
                          );
                      if (isUploaded && mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  : null,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // thumbnail
              Padding(
                padding: const EdgeInsets.all(16),
                child: CarouselSlider.builder(
                  itemCount: thumbnailRequestList.length,
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
                      thumbnailRequest: thumbnailRequestList[index],
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: Strings.pleaseWriteYourMessageHere,
                  ),
                  autofocus: true,
                  maxLines: null,
                  controller: postController,
                ),
              ),
              ...PostSettings.values.map(
                (postSetting) => ListTile(
                  title: Text(postSetting.title),
                  subtitle: Text(postSetting.description),
                  trailing: Switch(
                    value: postSettings[postSetting] ?? false,
                    onChanged: (isOn) {
                      ref.read(postSettingsProvider.notifier).setSetting(
                            postSetting,
                            isOn,
                          );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
