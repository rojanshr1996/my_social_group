import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/auth_state_provider.dart';
import 'package:tekk_gram/state/image_upload/helpers/image_picker_helper.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/login/divider_with_margins.dart';
import 'package:tekk_gram/views/login/google_button.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    appLogo,
                    height: Utilities.screenHeight(context) * 0.2,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      Strings.welcomeToAppName,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.loginButtonTextColor.withAlpha(350),
                          fontSize: 24),
                    ),
                    Text(
                      "${Strings.appName}, ",
                      textAlign: TextAlign.left,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 40),
                    ),
                  ],
                ),
                const DividerWithMargins(),
                Text(
                  Strings.logIntoYourAccount,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 30),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.loginButtonColor,
                    foregroundColor: AppColors.loginButtonTextColor,
                  ),
                  onPressed: () async {
                    ref.read(authStateProvider.notifier).loginWithGoogle();
                  },
                  child: const GoogleButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
