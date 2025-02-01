import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:client_flutter/models/social_user_info.dart';

Future<void> initializeKakaoSdk() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!,
  );
}

class KakaoService {
  Future<SocialUserInfo?> loginWithKakao() async {    
    try {
      if (await isKakaoTalkInstalled()) {
        return await _attemptLoginWithKakaoTalk();
      } else {
        return await _attemptLoginWithKakaoAccount();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<SocialUserInfo?> _attemptLoginWithKakaoTalk() async {
    try {
      await UserApi.instance.loginWithKakaoTalk();
      return await _handleKakaoLogin();
    } catch (error) {
      if (error is PlatformException && error.code == 'CANCELED') {
        rethrow;
      }

      return await _attemptLoginWithKakaoAccount();
    }
  }

  Future<SocialUserInfo?> _attemptLoginWithKakaoAccount() async {
    try {
      await UserApi.instance.loginWithKakaoAccount();
      
      return await _handleKakaoLogin();
    } catch (error) {
      if (error is PlatformException && error.code == 'CANCELED') {
        return null;
      }

      rethrow;
    }
  }

  Future<SocialUserInfo?> _handleKakaoLogin() async {
    try {
      final User user = await UserApi.instance.me();
      
      return SocialUserInfo(
        socialId: user.id.toString(),
        email: user.kakaoAccount?.email,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try{
      await UserApi.instance.logout();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> unlink() async {
    try {
      await UserApi.instance.unlink();
    } catch (error) {
      rethrow;
    }
  }
}
