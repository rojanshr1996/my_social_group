import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/auth_state.dart';
import 'package:tekk_gram/state/auth/notifiers/auth_state_notifier.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((_) => AuthStateNotifier());
