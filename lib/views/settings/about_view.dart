import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Strings.appName.toUpperCase(),
              style: Theme.of(context).textTheme.headline4?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              "Version 1.0",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: AppColors.loginButtonColor, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Text(
              "Contact:",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Text(
              "Rojan Shrestha \n rojan.shr1996@gmail.com",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.greyColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.copyright, size: 12, color: AppColors.greyColor),
                Text(
                  " Copyright TekkGram",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.greyColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
