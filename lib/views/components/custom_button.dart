import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final IconData? iconData;
  const CustomButton({super.key, required this.title, this.iconData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconData == null
              ? const SizedBox()
              : FaIcon(
                  FontAwesomeIcons.google,
                  color: AppColors.googleColor,
                ),
          SizedBox(width: iconData == null ? 0 : 15),
          Text(title),
        ],
      ),
    );
  }
}
