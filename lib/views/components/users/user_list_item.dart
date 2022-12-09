import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';
import 'package:tekk_gram/utils/constants.dart';

class UserListItem extends ConsumerWidget {
  final UserInfoModel userData;
  final VoidCallback? onTap;
  const UserListItem({super.key, required this.userData, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).bottomAppBarColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: userData.imageUrl == "" || userData.imageUrl == null
                    ? Image.asset(appLogo)
                    : Image.network(
                        userData.imageUrl!,
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
                  userData.displayName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  userData.email ?? "",
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
    );
  }
}
