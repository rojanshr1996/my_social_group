import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/providers/user_id_provider.dart';
import 'package:tekk_gram/state/posts/models/post.dart';

final canCurrentUserDeletePostProvider = StreamProvider.autoDispose.family<bool, Post>((ref, Post post) async* {
  final userId = ref.watch(userIdProvider);
  yield userId == post.userId;
});
