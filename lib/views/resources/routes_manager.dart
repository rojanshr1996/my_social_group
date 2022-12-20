import 'package:flutter/material.dart';
import 'package:tekk_gram/splash_screen.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/state/user_info/models/user_info_model.dart';
import 'package:tekk_gram/views/chat/chat_message_screen.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/login/login_view.dart';
import 'package:tekk_gram/views/main/main_view.dart';
import 'package:tekk_gram/views/post_details/post_details_view.dart';
import 'package:tekk_gram/views/post_details/post_edit_screen.dart';
import 'package:tekk_gram/views/profile/user_profile_view.dart';
import 'package:tekk_gram/views/profile/users_list_view.dart';
import 'package:tekk_gram/views/settings/help_and_support_view.dart';
import 'package:tekk_gram/views/settings/settings.dart';

class Routes {
  static const String splashRoute = "/";
  static const String loginRoute = "/login";
  static const String userProfile = "/user/profile";
  static const String mainRoute = "/main";
  static const String helpRoute = "/help";
  static const String profile = "/profile";
  static const String postDetailRoute = "/post/detail";
  static const String postEditRoute = "/post/edit";
  static const String commentRoute = "/comment";
  static const String chatRoute = "/chat";
  static const String userListRoute = "/user/list";
  static const String settings = "/settings";
  static const String createNewPost = "/post/create";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    switch (routeSettings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case Routes.mainRoute:
        return MaterialPageRoute(builder: (_) => const MainView());
      case Routes.userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileView());
      case Routes.userListRoute:
        return MaterialPageRoute(builder: (_) => const UsersListView());
      case Routes.helpRoute:
        return MaterialPageRoute(builder: (_) => const HelpAndSupport());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const Settings());
      case Routes.chatRoute:
        if (args != null && args is UserInfoModel) {
          return MaterialPageRoute(builder: (_) => ChatMessageScreen(userData: args));
        }
        return unDefinedRoute();
      case Routes.postDetailRoute:
        if (args != null && args is Post) {
          return MaterialPageRoute(builder: (_) => PostDetailsView(post: args));
        }
        return unDefinedRoute();
      case Routes.postEditRoute:
        if (args != null && args is Post) {
          return MaterialPageRoute(builder: (_) => PostEditScreen(post: args));
        }
        return unDefinedRoute();

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text(Strings.noRouteFound),
        ),
        body: const Center(child: Text(Strings.noRouteFound)),
      ),
    );
  }
}
