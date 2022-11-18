import 'package:hooks_riverpod/hooks_riverpod.dart';

class BottomNavBarScrollVisibilityNotifier extends StateNotifier<bool> {
  BottomNavBarScrollVisibilityNotifier() : super(true);

  void showBottomNavBar({required bool showBottomNavBar}) {
    state = showBottomNavBar;
  }
}
