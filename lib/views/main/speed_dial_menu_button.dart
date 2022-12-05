import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class SpeedDialMenuButton extends StatelessWidget {
  final VoidCallback onPhotoPressed;
  final VoidCallback onVideoPressed;
  const SpeedDialMenuButton({super.key, required this.onPhotoPressed, required this.onVideoPressed});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 24.0, color: AppColors.loginButtonTextColor),
      backgroundColor: AppColors.loginButtonColor,
      visible: true,
      curve: Curves.bounceInOut,
      childMargin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      spacing: 15,
      children: [
        SpeedDialChild(
          child: FaIcon(
            FontAwesomeIcons.film,
            color: AppColors.loginButtonColor,
          ),
          backgroundColor: AppColors.loginButtonTextColor,
          onTap: onVideoPressed,
          label: 'Video',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: AppColors.loginButtonColor),
          labelBackgroundColor: AppColors.loginButtonTextColor,
        ),
        SpeedDialChild(
          child: FaIcon(
            FontAwesomeIcons.image,
            color: AppColors.loginButtonColor,
          ),
          backgroundColor: AppColors.loginButtonTextColor,
          onTap: onPhotoPressed,
          label: 'Photo',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: AppColors.loginButtonColor),
          labelBackgroundColor: AppColors.loginButtonTextColor,
        ),
      ],
    );
  }
}
