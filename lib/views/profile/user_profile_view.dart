import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/auth_state_provider.dart';
import 'package:tekk_gram/state/image_upload/helpers/image_picker_helper.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/camera_gallery_selection_widget.dart';
import 'package:tekk_gram/views/components/dialogs/alert_dialog_model.dart';
import 'package:tekk_gram/views/components/dialogs/logout_dialog.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';

class UserProfileView extends ConsumerStatefulWidget {
  const UserProfileView({super.key});

  @override
  ConsumerState<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends ConsumerState<UserProfileView> {
  @override
  Widget build(BuildContext context) {
    final userInfoModel = ref.watch(userInfoModelProvider(FirebaseAuth.instance.currentUser!.uid));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(Strings.profile),
          backgroundColor: AppColors.transparent,
        ),
        body: userInfoModel.when(
          data: (userInfoModel) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Container(
                          height: Utilities.screenHeight(context) * 0.25,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white30, width: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(appLogo),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final imageFile = await openCameraOption(context);
                                log("IMAGE: $imageFile");
                                if (imageFile == null) {
                                  return;
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.loginButtonColor.withOpacity(0.5),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    userInfoModel.displayName,
                    style: Theme.of(context).textTheme.headline6?.copyWith(),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.solidEnvelope, color: AppColors.loginButtonColor, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                userInfoModel.email ?? "",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.phone, color: AppColors.loginButtonColor, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                " -- ",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      Strings.settings,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.white70),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            onTap: () async {
                              final shouldLogOut = await const LogoutDialog().present(context).then(
                                    (value) => value ?? false,
                                  );
                              if (shouldLogOut) {
                                await ref.read(authStateProvider.notifier).logOut();
                              }
                            },
                            leading: FaIcon(
                              FontAwesomeIcons.arrowRightFromBracket,
                              size: 20,
                              color: AppColors.loginButtonColor,
                            ),
                            title: const Text(Strings.logout),
                          ),
                        ),
                      ],
                    ),
                  )
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
                      Utilities.returnDataCloseActivity(context, videoFile);
                    } else {
                      final imageFile = await ImagePickerHelper.picImageFromCamera();
                      if (!mounted) return;
                      Utilities.returnDataCloseActivity(context, imageFile);
                    }
                  },
                  onGallaryTap: () async {
                    if (isVideo) {
                      final videoFile = await ImagePickerHelper.pickImageFromGallery();
                      if (!mounted) return;
                      Utilities.returnDataCloseActivity(context, videoFile);
                    } else {
                      final imageFile = await ImagePickerHelper.pickImageFromGallery();
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
