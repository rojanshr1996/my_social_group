import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/auth/auth_state.dart';
import 'package:tekk_gram/state/auth/backend/authenticator.dart';
import 'package:tekk_gram/state/auth/models/auth_result.dart';
import 'package:tekk_gram/state/constants/firebase_collection_name.dart';
import 'package:tekk_gram/state/constants/firebase_field_name.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';
import 'package:tekk_gram/state/user_info/backend/user_info_storage.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final _authenticator = Authenticator();
  final _userInfoStorage = const UserInfoStorage();
  AuthStateNotifier() : super(const AuthState.unknown()) {
    if (_authenticator.isAlreadyLoggedIn) {
      state = AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: _authenticator.userId,
      );
    }
  }

  Future<void> logOut() async {
    state = state.copiedWithIsLoading(true);
    await _authenticator.logOut();
    state = const AuthState.unknown();
  }

  Future<void> loginWithGoogle() async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.loginWithGoogle();
    final userId = _authenticator.userId;

    if (result == AuthResult.success && userId != null) {
      final userInfo = await FirebaseFirestore.instance
          .collection(
            FirebaseCollectionName.users,
          )
          .where(FirebaseFieldName.userId, isEqualTo: userId)
          .limit(1)
          .get();

      if (userInfo.docs.isEmpty) {
        await saveUserInfo(userId: userId);
      }
    }

    state = AuthState(result: result, isLoading: false, userId: userId);
  }

  Future<void> saveUserInfo({required UserId userId}) => _userInfoStorage.saveUserInfo(
        userId: userId,
        displayName: _authenticator.displayName,
        email: _authenticator.email,
        phone: _authenticator.phone,
        imageUrl: _authenticator.imageUrl,
      );

  Future<bool> updateUserInfo({
    required UserId userId,
    required String displayName,
    required String? phone,
    required String? imageUrl,
  }) async {
    state = state.copiedWithIsLoading(true);

    final result = await _userInfoStorage.saveUserInfo(
      userId: userId,
      displayName: displayName,
      email: _authenticator.email,
      phone: phone,
      imageUrl: imageUrl,
    );
    state = state.copiedWithIsLoading(false);
    return result;
  }
}
