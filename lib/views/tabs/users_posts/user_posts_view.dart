import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/home/providers/bottom_nav_bar_scroll_visibility_provider.dart';
import 'package:tekk_gram/state/posts/providers/user_posts_provider.dart';
import 'package:tekk_gram/state/toggle_view/toggle_posts_view_provider.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:tekk_gram/views/components/animations/error_animation_view.dart';
import 'package:tekk_gram/views/components/animations/loading_animation_view.dart';
import 'package:tekk_gram/views/components/post/post_list_view.dart';
import 'package:tekk_gram/views/components/post/posts_grid_view.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/profile/user_profile_view.dart';

class UserPostsView extends ConsumerWidget {
  const UserPostsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(authUserPostsProvider);

    final userInfoModel = ref.watch(userInfoModelProvider(FirebaseAuth.instance.currentUser!.uid));
    final showBottomNavBar = ref.watch(bottomNavBarScrollVisibilityProvider);

    final toggleValue = ref.watch(togglePostsViewProvider);

    return RefreshIndicator(
      onRefresh: () {
        ref.refresh(authUserPostsProvider);
        return Future.delayed(const Duration(seconds: 1));
      },
      child: userInfoModel.when(
        data: (userInfoModel) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Container(
                  width: Utilities.screenWidth(context),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {
                        Utilities.openActivity(context, const UserProfileView());
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).bottomAppBarColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: userInfoModel.imageUrl == "" || userInfoModel.imageUrl == null
                                    ? Image.asset(appLogo)
                                    : Image.network(
                                        userInfoModel.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  userInfoModel.displayName,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userInfoModel.email ?? "",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.white70,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: posts.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const EmptyContentsWithTextAnimationView(
                        text: Strings.youHaveNoPosts,
                      );
                    } else {
                      return toggleValue ? PostsGridView(posts: posts) : PostsListView(posts: posts);
                    }
                  },
                  error: ((error, stackTrace) {
                    return const ErrorAnimationView();
                  }),
                  loading: () {
                    return const LoadingAnimationView();
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return const SizedBox.shrink();
        },
        loading: () {
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
