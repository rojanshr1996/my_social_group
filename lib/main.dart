import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/auth_state_provider.dart';

import 'dart:developer' as devtools show log;

import 'package:tekk_gram/state/auth/providers/is_logged_in_provider.dart';
import 'package:tekk_gram/state/providers/is_loading_provider.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/loading/loading_screen.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TekkGram',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        indicatorColor: Colors.blueGrey,
      ),
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'poppins',
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: Consumer(builder: (context, ref, child) {
        ref.listen<bool>(isLoadingProvider, (_, isLoading) {
          if (isLoading) {
            LoadingScreen.instance().show(context: context);
          } else {
            LoadingScreen.instance().hide();
          }
        });
        final isLoggedIn = ref.watch(isLoggedInProvider);

        if (isLoggedIn) {
          return const HomeView();
        } else {
          return const LoginView();
        }
      }),
    );
  }
}

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text("Login"),
        // ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  appLogo,
                  height: Utilities.screenHeight(context) * 0.2,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                "Welcome to TekkGram,",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline4?.copyWith(fontWeight: FontWeight.w500, fontSize: 25),
              ),
              const SizedBox(height: 50),
              Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).loginWithGoogle();
                  },
                  child: const Text("Sign In with Google"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main View"),
      ),
      body: Consumer(
        builder: (_, ref, child) {
          return Column(
            children: [
              TextButton(
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logOut();
                  // LoadingScreen.instance().show(context: context, text: "Hello World");
                },
                child: const Text("Log out"),
              ),
            ],
          );
        },
      ),
    );
  }
}
