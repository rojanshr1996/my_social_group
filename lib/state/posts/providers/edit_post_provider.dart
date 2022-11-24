import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/image_upload/typedefs/is_loading.dart';
import 'package:tekk_gram/state/posts/notifiers/edit_post_notifier.dart';

final editPostProvider = StateNotifierProvider<EditPostNotifier, IsLoading>(
  (ref) => EditPostNotifier(),
);
