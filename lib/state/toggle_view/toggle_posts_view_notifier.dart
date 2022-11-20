import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/home/typdefs/toggle_view.dart';

class TogglePostsViewNotifier extends StateNotifier<ToggleView> {
  TogglePostsViewNotifier() : super(false);

  ToggleView get toogleValue => state;

  void togglePostsView(ToggleView toggleView) {
    state = toggleView;
  }
}
