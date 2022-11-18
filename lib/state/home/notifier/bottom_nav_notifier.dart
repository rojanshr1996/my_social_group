import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/home/typedefs/bottom_nav_index.dart';

class BottomNavNotifier extends StateNotifier<BottomNavIndex> {
  BottomNavNotifier() : super(0);

  void changeIndex({required BottomNavIndex index}) {
    state = index;
  }
}
