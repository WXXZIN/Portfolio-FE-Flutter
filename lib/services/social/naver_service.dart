import 'package:flutter_naver_login/flutter_naver_login.dart';

import 'package:client_flutter/models/social_user_info.dart';

class NaverService {

  Future<SocialUserInfo?> loginWithNaver() async {
    try {
      final result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        return _handleNaverLogin(result);
      } else {
        return null;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<SocialUserInfo> _handleNaverLogin(NaverLoginResult result) async {
    try {
      final NaverAccountResult account = result.account;

      return SocialUserInfo(
        socialId: account.id.toString(),
        email: account.email,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await FlutterNaverLogin.logOut();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logoutAndDeleteToken() async {
    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
    } catch (error) {
      rethrow;
    }
  }
}