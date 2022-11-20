import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/comments/notifiers/delete_comment_notifier.dart';
import 'package:tekk_gram/state/image_upload/typedefs/is_loading.dart';

final deleteCommentProvider = StateNotifierProvider<DeleteCommentStateNotifier, IsLoading>(
  (ref) => DeleteCommentStateNotifier(),
);
