import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/main.dart';
import 'package:tekk_gram/state/auth/providers/is_logged_in_provider.dart';
import 'package:tekk_gram/state/providers/is_loading_provider.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/loading/loading_screen.dart';
import 'package:tekk_gram/views/login/login_view.dart';
import 'package:tekk_gram/views/main/main_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Utilities.removeStackActivity(context, const IndexScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: Utilities.screenHeight(context),
        width: Utilities.screenWidth(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Image.asset(appLogo),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.listen<bool>(
          isLoadingProvider,
          (_, isLoading) {
            ("LOADER STATUS: $isLoading").log();

            if (isLoading) {
              LoadingScreen.instance().show(context: context);
            } else {
              LoadingScreen.instance().hide();
            }
          },
        );
        final isLoggedIn = ref.watch(isLoggedInProvider);

        if (isLoggedIn) {
          return const MainView();
        } else {
          return const LoginView();
        }
      },
    );
  }
}
