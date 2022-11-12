import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/post_settings/models/post_settings.dart';
import 'package:tekk_gram/state/post_settings/notifiers/post_settings_notifier.dart';

final postSettingsProvider = StateNotifierProvider<PostSettingsNotifier, Map<PostSettings, bool>>(
  (ref) => PostSettingsNotifier(),
);
