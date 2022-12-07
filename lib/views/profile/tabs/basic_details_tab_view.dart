import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class BasicDetailsTabView extends StatelessWidget {
  final UserInfoModel userData;
  const BasicDetailsTabView({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        userData.email ?? "",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.phone, color: AppColors.loginButtonColor, size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        userData.phone == "" ? " -- " : userData.phone!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
