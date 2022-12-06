import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/image_upload/helpers/image_picker_helper.dart';
import 'package:tekk_gram/state/image_upload/models/thumbnail_request.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/camera_gallery_selection_widget.dart';
import 'package:tekk_gram/views/components/enlarge_image.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/login/divider_with_margins.dart';
import 'package:tekk_gram/views/profile/profile_image_view.dart';
import 'package:tekk_gram/views/profile/tabs/basic_details_tab_view.dart';
import 'package:tekk_gram/views/profile/tabs/posts_list_tab_view.dart';

class PostUserProfileView extends StatefulHookConsumerWidget {
  final UserId userId;
  const PostUserProfileView({super.key, required this.userId});

  @override
  ConsumerState<PostUserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends ConsumerState<PostUserProfileView> {
  // ThumbnailRequest? thumbnailRequest;

  @override
  Widget build(BuildContext context) {
    final userInfoModel = ref.watch(userInfoModelProvider(widget.userId));
    final thumbnailRequest = useState<ThumbnailRequest?>(null);

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: RemoveFocus(
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: const Text(Strings.profile),
              backgroundColor: AppColors.transparent,
            ),
            body: userInfoModel.when(
              data: (userInfoModel) {
                return NestedScrollView(
                  // controller: _sc,
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: thumbnailRequest.value == null
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
                                            Utilities.openActivity(
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
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 4),
                              child: Text(
                                userInfoModel.displayName,
                                style: Theme.of(context).textTheme.headline6?.copyWith(),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),
                            const DividerWithMargins(margin: 10),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: SizedBox(
                    height: Utilities.screenHeight(context),
                    width: Utilities.screenWidth(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: Builder(builder: (BuildContext context) {
                              final TabController tabController = DefaultTabController.of(context)!;
                              tabController.addListener(() {
                                setState(() {});
                              });
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: TabBar(
                                        indicator: UnderlineTabIndicator(
                                            borderSide: BorderSide(width: 4, color: AppColors.loginButtonColor),
                                            insets: const EdgeInsets.only(right: 16, left: 12, bottom: 5, top: 2)),
                                        labelPadding: const EdgeInsets.only(right: 16, left: 16),
                                        unselectedLabelColor: AppColors.greyColor,
                                        labelColor: AppColors.loginButtonTextColor,
                                        isScrollable: true,
                                        labelStyle: Theme.of(context).textTheme.subtitle1,
                                        // unselectedLabelStyle: CustomTextStyle.subtitleText
                                        //     .copyWith(fontWeight: medium, fontFamily: "euclid"),
                                        tabs: const <Widget>[
                                          Tab(text: "Basic Detail"),
                                          Tab(text: "Posts"),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      physics: const NeverScrollableScrollPhysics(),
                                      children: <Widget>[
                                        BasicDetailsTabView(userData: userInfoModel),
                                        PostsListTabView(userData: userInfoModel),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
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
