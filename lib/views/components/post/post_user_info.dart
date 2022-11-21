import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class PostUserInfo extends StatelessWidget {
  final DateTime createdAt;
  final String displayName;
  final String imageUrl;
  const PostUserInfo({super.key, required this.createdAt, required this.displayName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMM, yyyy, h:mm a');

    return Container(
      // height: Utilities.screenHeight(context) * 0.088,
      width: Utilities.screenWidth(context),
      decoration: BoxDecoration(
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
                  child: imageUrl == ""
                      ? Image.asset(appLogo)
                      : Image.network(
                          imageUrl,
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
                    displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatter.format(createdAt),
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
  }
}
