import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/home/typdefs/toggle_view.dart';
import 'package:tekk_gram/state/toggle_view/toggle_posts_view_notifier.dart';

final togglePostsViewProvider = StateNotifierProvider<TogglePostsViewNotifier, ToggleView>(
  (_) => TogglePostsViewNotifier(),
);
