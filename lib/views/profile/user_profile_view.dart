import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/auth_state_provider.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/home/providers/botton_nav_index_provider.dart';
import 'package:tekk_gram/state/image_upload/helpers/image_picker_helper.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/image_upload/models/thumbnail_request.dart';
import 'package:tekk_gram/state/image_upload/providers/image_uploader_provider.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/camera_gallery_selection_widget.dart';
import 'package:tekk_gram/views/components/dialogs/alert_dialog_model.dart';
import 'package:tekk_gram/views/components/dialogs/logout_dialog.dart';
import 'package:tekk_gram/views/components/enlarge_image.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/profile/profile_image_view.dart';

class UserProfileView extends StatefulHookConsumerWidget {
  const UserProfileView({super.key});

  @override
  ConsumerState<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends ConsumerState<UserProfileView> {
  // ThumbnailRequest? thumbnailRequest;

  @override
  Widget build(BuildContext context) {
    final userInfoModel = ref.watch(userInfoModelProvider(FirebaseAuth.instance.currentUser!.uid));
    final editPhone = useState(false);
    final editName = useState(false);

    final thumbnailRequest = useState<ThumbnailRequest?>(null);
    final imageFile = useState<File?>(null);

    return SafeArea(
      child: RemoveFocus(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text(Strings.profile),
            backgroundColor: AppColors.transparent,
          ),
          body: userInfoModel.when(
            data: (userInfoModel) {
              final nameController = useTextEditingController(text: userInfoModel.displayName);
              final phoneController = useTextEditingController(text: userInfoModel.phone ?? "");

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          thumbnailRequest.value == null
                              ? userInfoModel.imageUrl == "" || userInfoModel.imageUrl == null
                                  ? Container(
                                      height: Utilities.screenHeight(context) * 0.35,
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
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        Utilities.fadeOpenActivity(
                                            context, EnlargeImage(imageUrl: userInfoModel.imageUrl!));
                                      },
                                      child: Container(
                                        height: Utilities.screenHeight(context) * 0.35,
                                        width: Utilities.screenWidth(context),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          width: Utilities.screenWidth(context),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.white30, width: 0.5),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              userInfoModel.imageUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                              : Container(
                                  height: Utilities.screenHeight(context) * 0.35,
                                  width: Utilities.screenWidth(context),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    width: Utilities.screenWidth(context),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white30, width: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: ProfileImageView(thumbnailRequest: thumbnailRequest.value!),
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
                                  final image = await openCameraOption(context);
                                  log("IMAGE: $imageFile");
                                  if (image == null) {
                                    return;
                                  }
                                  imageFile.value = image;
                                  thumbnailRequest.value =
                                      ThumbnailRequest(file: imageFile.value!, fileType: FileType.userImage);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.loginButtonColor.withOpacity(0.75),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.camera_alt, size: 20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          thumbnailRequest.value == null
                              ? const SizedBox()
                              : Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final userId = ref.read(userIdProvider);
                                        if (userId == null) {
                                          return;
                                        }
                                        final isUploaded = await ref.read(imageUploadProvider.notifier).upload(
                                              file: imageFile.value!,
                                              fileType: FileType.userImage,
                                              userId: userId,
                                              userData: userInfoModel,
                                            );
                                        if (isUploaded && mounted) {
                                          ref.refresh(userInfoModelProvider(userId));
                                          thumbnailRequest.value = null;
                                          imageFile.value = null;
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.greenColor.withOpacity(0.75),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(Icons.check, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: editName.value
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: Strings.enterYourName,
                                    ),
                                    autofocus: false,
                                    maxLines: null,
                                    controller: nameController,
                                    onSubmitted: (value) async {
                                      if (value.isNotEmpty) {
                                        if (value.trim() != userInfoModel.phone?.trim()) {
                                          final result = await ref.read(authStateProvider.notifier).updateUserInfo(
                                                userId: userInfoModel.userId,
                                                displayName: value.trim(),
                                                phone: userInfoModel.phone,
                                                imageUrl: userInfoModel.imageUrl,
                                              );

                                          if (result) {
                                            ref.refresh(userInfoModelProvider(FirebaseAuth.instance.currentUser!.uid));
                                          }
                                        }
                                      }
                                    },
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 4),
                                  child: Text(
                                    userInfoModel.displayName,
                                    style: Theme.of(context).textTheme.headline6?.copyWith(),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 16),
                          child: GestureDetector(
                            onTap: () async {
                              editName.value = !editName.value;

                              if (nameController.text.isNotEmpty) {
                                if (nameController.text.trim() != userInfoModel.displayName.trim()) {
                                  final result = await ref.read(authStateProvider.notifier).updateUserInfo(
                                        userId: userInfoModel.userId,
                                        displayName: nameController.text.trim(),
                                        phone: userInfoModel.phone,
                                        imageUrl: userInfoModel.imageUrl,
                                      );
                                  log("This is the result: $result");
                                  if (result) {
                                    ref.refresh(userInfoModelProvider(FirebaseAuth.instance.currentUser!.uid));
                                  }
                                }
                              }
                            },
                            child: editName.value
                                ? const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: FaIcon(FontAwesomeIcons.check, size: 18, color: Colors.white70),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: FaIcon(FontAwesomeIcons.pencil, color: Colors.white70, size: 18),
                                  ),
                          ),
                        ),
                      ],
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
                                Expanded(
                                  child: Text(
                                    userInfoModel.email ?? "",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                FaIcon(FontAwesomeIcons.phone, color: AppColors.loginButtonColor, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: editPhone.value
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              labelText: Strings.enterYourPhoneNumber,
                                            ),
                                            autofocus: false,
                                            maxLines: null,
                                            controller: phoneController,
                                            onSubmitted: (value) async {
                                              if (value.isNotEmpty) {
                                                if (value.trim() != userInfoModel.phone?.trim()) {
                                                  final result =
                                                      await ref.read(authStateProvider.notifier).updateUserInfo(
                                                            userId: userInfoModel.userId,
                                                            displayName: userInfoModel.displayName,
                                                            phone: value.trim(),
                                                            imageUrl: userInfoModel.imageUrl,
                                                          );

                                                  if (result) {
                                                    ref.refresh(
                                                        userInfoModelProvider(FirebaseAuth.instance.currentUser!.uid));
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        )
                                      : Text(
                                          userInfoModel.phone == "" ? " -- " : userInfoModel.phone!,
                                          style:
                                              Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                        ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    editPhone.value = !editPhone.value;

                                    if (phoneController.text.isNotEmpty) {
                                      if (phoneController.text.trim() != userInfoModel.phone?.trim()) {
                                        final result = await ref.read(authStateProvider.notifier).updateUserInfo(
                                              userId: userInfoModel.userId,
                                              displayName: userInfoModel.displayName,
                                              phone: phoneController.text.trim(),
                                              imageUrl: userInfoModel.imageUrl,
                                            );
                                        log("This is the result: $result");
                                        if (result) {
                                          ref.refresh(userInfoModelProvider(FirebaseAuth.instance.currentUser!.uid));
                                        }
                                      }
                                    }
                                  },
                                  child: editPhone.value
                                      ? const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: FaIcon(FontAwesomeIcons.check, size: 18, color: Colors.white70),
                                        )
                                      : const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: FaIcon(FontAwesomeIcons.pencil, color: Colors.white70, size: 18),
                                        ),
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
                                if (shouldLogOut && mounted) {
                                  Utilities.closeActivity(context);
                                  ref.read(bottomNavIndexProvider.notifier).changeIndex(index: 0);
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
