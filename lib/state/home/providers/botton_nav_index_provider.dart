import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/home/notifier/bottom_nav_notifier.dart';
import 'package:tekk_gram/state/home/typedefs/bottom_nav_index.dart';

final bottomNavIndexProvider = StateNotifierProvider<BottomNavNotifier, BottomNavIndex>(
  (_) => BottomNavNotifier(),
);
