import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/auth_state_provider.dart';
import 'package:tekk_gram/state/home/providers/botton_nav_index_provider.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/dialogs/alert_dialog_model.dart';
import 'package:tekk_gram/views/components/dialogs/logout_dialog.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/settings/about_view.dart';
import 'package:tekk_gram/views/settings/help_and_support_view.dart';

class Settings extends StatefulHookConsumerWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends ConsumerState<Settings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RemoveFocus(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            title: const Text(Strings.settings),
            backgroundColor: AppColors.transparent,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        SettingsTile(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (_) {
                                  return const AboutView();
                                });
                          },
                          iconData: FontAwesomeIcons.info,
                          title: "About",
                        ),
                        SettingsTile(
                          iconData: FontAwesomeIcons.headset,
                          title: "Help & Support",
                          onPressed: () {
                            Utilities.openActivity(context, const HelpAndSupport());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      onTap: () async {
                        final shouldLogOut = await const LogoutDialog().present(context).then(
                              (value) => value ?? false,
                            );
                        if (shouldLogOut && mounted) {
                          Utilities.doubleBack(context);
                          ref.read(bottomNavIndexProvider.notifier).changeIndex(index: 0);
                          await ref.read(authStateProvider.notifier).logOut();
                        }
                      },
                      leading: FaIcon(
                        FontAwesomeIcons.arrowRightFromBracket,
                        size: 20,
                        color: AppColors.loginButtonColor,
                      ),
                      title: const Text(Strings.logout),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final VoidCallback? onPressed;
  const SettingsTile({super.key, required this.iconData, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ListTile(
        onTap: onPressed,
        leading: FaIcon(
          iconData,
          size: 20,
          color: AppColors.loginButtonColor,
        ),
        title: Text(
          title,
        ),
      ),
    );
  }
}
