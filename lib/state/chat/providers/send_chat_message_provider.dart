import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/chat/notifier/chat_message_notifier.dart';
import 'package:tekk_gram/state/image_upload/typedefs/is_loading.dart';

final sendChatMessageProvider = StateNotifierProvider<ChatMessageNotifier, IsLoading>(
  (ref) => ChatMessageNotifier(),
);
