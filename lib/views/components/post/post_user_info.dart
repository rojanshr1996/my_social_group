import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class PostUserInfo extends ConsumerWidget {
  final Post postData;
  final bool removeDecoration;

  const PostUserInfo({super.key, required this.postData, this.removeDecoration = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormat('d MMM, yyyy, h:mm a');
    final userInfoModel = ref.watch(userInfoModelProvider(postData.userId));

    return userInfoModel.when(
      data: (userInfoModel) {
        return Container(
          // height: Utilities.screenHeight(context) * 0.088,
          width: Utilities.screenWidth(context),
          decoration: removeDecoration
              ? const BoxDecoration()
              : BoxDecoration(
                  gradient: AppColors.topDarkGradient,
                ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).bottomAppBarColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userInfoModel.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        postData.createdAt == null ? "" : formatter.format(postData.createdAt!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 5),
                    ],
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
    );
  }
}
