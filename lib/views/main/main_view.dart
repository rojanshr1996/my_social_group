import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/auth_state_provider.dart';
import 'package:tekk_gram/state/home/providers/bottom_nav_bar_scroll_visibility_provider.dart';
import 'package:tekk_gram/state/home/providers/botton_nav_index_provider.dart';
import 'package:tekk_gram/state/image_upload/helpers/image_picker_helper.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/post_settings/providers/post_settings_provider.dart';
import 'package:tekk_gram/state/toggle_view/toggle_posts_view_provider.dart';
import 'package:tekk_gram/views/components/dialogs/alert_dialog_model.dart';
import 'package:tekk_gram/views/components/dialogs/logout_dialog.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/create_new_post/create_new_post_view.dart';
import 'package:tekk_gram/views/tabs/home/home_view.dart';
import 'package:tekk_gram/views/tabs/search/search_view.dart';
import 'package:tekk_gram/views/tabs/users_posts/user_posts_view.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  static const List<Widget> _widgetOptions = <Widget>[HomeView(), SearchView(), UserPostsView()];

  @override
  Widget build(BuildContext context) {
    // final bottomNavIndex = ref.watch(isIndexChangedProvider);
    final bottomNavIndex = ref.watch(bottomNavIndexProvider);
    final showBottomNavBar = ref.watch(bottomNavBarScrollVisibilityProvider);

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: const Text(Strings.appName),
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.film),
              onPressed: () async {
                // pick a video first
                final videoFile = await ImagePickerHelper.pickVideoFromGallery();
                if (videoFile == null) {
                  return;
                }

                // reset the postSettingProvider
                ref.refresh(postSettingsProvider);

                // go to the screen to create a new post
                if (!mounted) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateNewPostView(
                      fileType: FileType.video,
                      fileToPost: videoFile,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () async {
                // pick an image first
                final imageFile = await ImagePickerHelper.pickImageFromGallery();
                if (imageFile == null) {
                  return;
                }
                // reset the postSettingProvider
                ref.refresh(postSettingsProvider);

                // go to the screen to create a new post
                if (!mounted) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateNewPostView(
                      fileType: FileType.image,
                      fileToPost: imageFile,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
            IconButton(
              onPressed: () async {
                final shouldLogOut = await const LogoutDialog().present(context).then(
                      (value) => value ?? false,
                    );
                if (shouldLogOut) {
                  await ref.read(authStateProvider.notifier).logOut();
                }
              },
              icon: const Icon(
                Icons.logout,
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final toggleValue = ref.watch(togglePostsViewProvider);

                // final toggleView = ;
                return IconButton(
                  onPressed: () async {
                    ref.read(togglePostsViewProvider.notifier).togglePostsView(!toggleValue);
                  },
                  icon: toggleValue ? const Icon(Icons.grid_3x3) : const Icon(Icons.filter_list),
                );
              },
            ),
          ],
        ),
        body: _widgetOptions.elementAt(bottomNavIndex),
        bottomNavigationBar: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: showBottomNavBar ? 1 : 0,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      ),
    );
  }
}
