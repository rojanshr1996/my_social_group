import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class PostUserInfo extends StatelessWidget {
  final DateTime createdAt;
  final String displayName;
  const PostUserInfo({super.key, required this.createdAt, required this.displayName});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMM, yyyy, h:mm a');

    return Container(
      height: Utilities.screenHeight(context) * 0.065,
      width: Utilities.screenWidth(context),
      decoration: BoxDecoration(
        gradient: AppColors.topDarkGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              formatter.format(createdAt),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
