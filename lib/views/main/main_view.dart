// ignore_for_file: unused_result

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/home/providers/bottom_nav_bar_scroll_visibility_provider.dart';
import 'package:tekk_gram/state/home/providers/botton_nav_index_provider.dart';
import 'package:tekk_gram/state/image_upload/helpers/image_picker_helper.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/post_settings/providers/post_settings_provider.dart';
import 'package:tekk_gram/state/toggle_view/toggle_posts_view_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/chat/user_search_list_screen.dart';
import 'package:tekk_gram/views/components/camera_gallery_selection_widget.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/create_new_post/create_new_post_list_view.dart';
import 'package:tekk_gram/views/create_new_post/create_new_post_view.dart';
import 'package:tekk_gram/views/main/speed_dial_menu_button.dart';
import 'package:tekk_gram/views/tabs/home/home_view.dart';
import 'package:tekk_gram/views/tabs/search/search_view.dart';
import 'package:tekk_gram/views/tabs/users_posts/user_posts_view.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  static const List<Widget> _widgetOptions = <Widget>[
    HomeView(),
    SearchView(),
    UserPostsView(),
  ];

  @override
  Widget build(BuildContext context) {
    // final bottomNavIndex = ref.watch(isIndexChangedProvider);
    final bottomNavIndex = ref.watch(bottomNavIndexProvider);
    final showBottomNavBar = ref.watch(bottomNavBarScrollVisibilityProvider);
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          elevation: 0,
          title: const Text(Strings.appName),
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.transparent,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IconButton(
                onPressed: () {
                  Utilities.openActivity(context, const UserSearchListScreen());
                  // Utilities.openActivity(context, const UsersListView());
                },
                icon: const FaIcon(
                  FontAwesomeIcons.comments,
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Consumer(
              builder: (contzext, ref, child) {
                final toggleValue = ref.watch(togglePostsViewProvider);
                return Container(
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Theme.of(context).bottomAppBarTheme.color!))),
                  child: Column(
                    children: [
                      bottomNavIndex == 1
                          ? const SizedBox()
                          : Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: toggleValue ? AppColors.transparent : AppColors.loginButtonColor),
                                      child: GestureDetector(
                                        onTap: () {
                                          ref.read(togglePostsViewProvider.notifier).togglePostsView(!toggleValue);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.filter_list),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: toggleValue ? AppColors.loginButtonColor : AppColors.transparent),
                                      child: GestureDetector(
                                        onTap: () {
                                          ref.read(togglePostsViewProvider.notifier).togglePostsView(!toggleValue);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.grid_3x3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: _widgetOptions.elementAt(bottomNavIndex),
            ),
          ],
        ),
        bottomNavigationBar: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: showBottomNavBar ? 1 : 0,
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BottomNavigationBar(
                      backgroundColor: AppColors.loginButtonColor,
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: FaIcon(FontAwesomeIcons.house),
                          ),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: FaIcon(FontAwesomeIcons.magnifyingGlass),
                          ),
                          label: 'Search',
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: FaIcon(FontAwesomeIcons.user),
                          ),
                          label: 'User',
                        ),
                      ],
                      currentIndex: bottomNavIndex,
                      iconSize: 18,
                      selectedFontSize: 12,
                      selectedItemColor: AppColors.googleColor,
                      onTap: (value) {
                        ref.read(bottomNavIndexProvider.notifier).changeIndex(index: value);
                      },
                      // showSelectedLabels: false,
                      showUnselectedLabels: false,
                      enableFeedback: true,
                    ),
                  ),
                ),
              ),
              bottomNavIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SpeedDialMenuButton(
                        onPhotoPressed: () {
                          openCameraOption(context).then((imageFile) {
                            if (imageFile == null) {
                              return;
                            }
                            // reset the postSettingProvider
                            ref.refresh(postSettingsProvider);
                            // go to the screen to create a new post
                            if (!mounted) {
                              return;
                            }
                          });
                        },
                        onVideoPressed: () async {
                          // pick a video first
                          final videoFile = await openCameraOption(context, isVideo: true);
                          if (videoFile == null) {
                            return;
                          }
                          // reset the postSettingProvider
                          ref.refresh(postSettingsProvider);
                          // go to the screen to create a new post
                          if (!mounted) {
                            return;
                          }
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
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
                      // Utilities.returnDataCloseActivity(context, videoFile);
                      if (videoFile != null) {
                        ref.refresh(postSettingsProvider);
                        Utilities.closeActivity(ctx);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateNewPostView(fileType: FileType.video, fileToPost: videoFile),
                          ),
                        );
                      }
                    } else {
                      final imageFile = await ImagePickerHelper.picImageFromCamera();

                      if (!mounted) return;
                      if (imageFile != null) {
                        ref.refresh(postSettingsProvider);
                        Utilities.closeActivity(ctx);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateNewPostListView(
                              fileType: FileType.image,
                              fileToPost: [imageFile],
                            ),
                          ),
                        );
                      }
                    }
                  },
                  onGallaryTap: () async {
                    if (isVideo) {
                      final videoFile = await ImagePickerHelper.pickVideoFromGallery();
                      if (!mounted) return;
                      // Utilities.returnDataCloseActivity(context, videoFile);
                      if (videoFile != null) {
                        ref.refresh(postSettingsProvider);
                        Utilities.closeActivity(ctx);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateNewPostView(fileType: FileType.video, fileToPost: videoFile),
                          ),
                        );
                      }
                    } else {
                      final imageFile = await ImagePickerHelper.pickMultiImageFromGallery();
                      log("IMAGE: $imageFile");

                      if (!mounted) return;
                      // Utilities.returnDataCloseActivity(context, imageFile);
                      Utilities.closeActivity(ctx);

                      if (imageFile.isNotEmpty) {
                        ref.refresh(postSettingsProvider);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateNewPostListView(
                              fileType: FileType.image,
                              fileToPost: imageFile,
                            ),
                          ),
                        );
                      }
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
