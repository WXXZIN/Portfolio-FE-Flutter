import 'package:google_sign_in/google_sign_in.dart';
import 'package:client_flutter/models/social_user_info.dart';

class GoogleService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<SocialUserInfo?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        return null;
      }

      return await _handleGoogleLogin(account);
    } catch (error) {
      rethrow;
    }
  }

  Future<SocialUserInfo> _handleGoogleLogin(GoogleSignInAccount account) async {
    try {
      return SocialUserInfo(
        socialId: account.id,
        email: account.email,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      rethrow;
    }
  }
}
