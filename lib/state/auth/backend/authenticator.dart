import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tekk_gram/state/auth/constants/constants.dart';
import 'package:tekk_gram/state/auth/models/auth_result.dart';
import 'package:tekk_gram/state/posts/typedefs/user_id.dart';

class Authenticator {
  UserId? get userId => FirebaseAuth.instance.currentUser?.uid;
  bool get isAlreadyLoggedIn => userId != null;
  String get displayName =>
      FirebaseAuth.instance.currentUser?.displayName ?? "";
  String? get email => FirebaseAuth.instance.currentUser?.email;
  String? get phone => FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
  String? get imageUrl => FirebaseAuth.instance.currentUser?.photoURL ?? "";

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  Future<AuthResult> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          Constants.emailScope,
        ],
      );
      final signInAccount = await googleSignIn.signIn();
      if (signInAccount == null) {
        return AuthResult.aborted;
      }
      final googleAuth = await signInAccount.authentication;
      final oauthCredentials = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      await FirebaseAuth.instance.signInWithCredential(oauthCredentials);

      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }
}
