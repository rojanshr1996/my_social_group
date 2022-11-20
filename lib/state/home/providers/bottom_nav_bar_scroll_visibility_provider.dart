import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/home/notifier/bottom_nav_scroll_visibility_notifier.dart';

final bottomNavBarScrollVisibilityProvider = StateNotifierProvider<BottomNavBarScrollVisibilityNotifier, bool>(
  (_) => BottomNavBarScrollVisibilityNotifier(),
);
