import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client_flutter/api/user_auth_api.dart';
import 'package:client_flutter/models/social_user_info.dart';
import 'package:client_flutter/models/user.dart';
import 'package:client_flutter/services/device/device_service.dart';
import 'package:client_flutter/services/social/google_service.dart';
import 'package:client_flutter/services/social/kakao_service.dart';
import 'package:client_flutter/services/social/naver_service.dart';

class UserAuthService {
  final FlutterSecureStorage _storage;
  final SharedPreferences _sharedPreferences;
  final UserAuthApi _userAuthApi;
  final DeviceService _deviceService;
  final GoogleService _googleService;
  final KakaoService _kakaoService;
  final NaverService _naverService;

  UserAuthService({
    FlutterSecureStorage? storage,
    SharedPreferences? sharedPreferences,
    UserAuthApi? userAuthApi,
    DeviceService? deviceService,
    GoogleService? googleService,
    KakaoService? kakaoService,
    NaverService? naverService,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _sharedPreferences = sharedPreferences!,
        _userAuthApi = userAuthApi ?? UserAuthApi(),
        _deviceService = deviceService ?? DeviceService(),
        _googleService = googleService ?? GoogleService(),
        _kakaoService = kakaoService ?? KakaoService(),
        _naverService = naverService ?? NaverService();

  static Future<UserAuthService> create() async {
    final storage = FlutterSecureStorage();
    final sharedPreferences = await SharedPreferences.getInstance();
    final userAuthApi = UserAuthApi();
    final deviceService = DeviceService();
    final googleService = GoogleService();
    final kakaoService = KakaoService();
    final naverService = NaverService();

    return UserAuthService(
      storage: storage,
      sharedPreferences: sharedPreferences,
      userAuthApi: userAuthApi,
      deviceService: deviceService,
      googleService: googleService,
      kakaoService: kakaoService,
      naverService: naverService,
    );
  }

  Future<User> localLogin({
    required String username,
    required String password,
    required bool isAutoLogin
  }) async {
    try {
      final deviceInfo = await _deviceService.getDeviceInfo();

      final response = await _userAuthApi.localLogin(
        username: username,
        password: password,
        os: deviceInfo['model'],
        deviceName: deviceInfo['deviceName'],
      );

      final accessToken = _extractToken(response.headers['authorization'], 'Bearer ');
      final refreshToken = _extractCookie(response.headers['Set-Cookie'], 0);
      final deviceId = _extractCookie(response.headers['Set-Cookie'], 1);

      if (accessToken != null && refreshToken != null && deviceId != null) {
        await saveSecureInfo(accessToken: accessToken, refreshToken: refreshToken, deviceId: deviceId);
        await saveUserInfo(nickname: response.data['data']['nickname'], email: response.data['data']['email'], provider: null, isAutoLogin: isAutoLogin);

        return User.fromJson(response.data['data']);
      } else {
        throw '토큰 정보가 없습니다.';
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<User?> socialLogin({
    required String provider
  }) async {
    try {
      final socialUserInfo = await _getUserInfo(provider);

      if (socialUserInfo == null) return null;

      final deviceInfo = await _deviceService.getDeviceInfo();

      final response = await _sendUserInfoToServer(
        provider: provider,
        socialId: socialUserInfo.socialId,
        email: socialUserInfo.email,
        os: deviceInfo['model'],
        deviceName: deviceInfo['deviceName'],
      );

      final accessToken = _extractToken(response.headers['authorization'], 'Bearer ');
      final refreshToken = _extractCookie(response.headers['Set-Cookie'], 0);
      final deviceId = _extractCookie(response.headers['Set-Cookie'], 1);

      if (accessToken != null && refreshToken != null && deviceId != null) {
        await saveSecureInfo(accessToken: accessToken, refreshToken: refreshToken, deviceId: deviceId);
        await saveUserInfo(nickname: response.data['data']['nickname'], email: response.data['data']['email'], provider: provider, isAutoLogin: true);

        return User.fromJson(response.data['data']);
      } else {
        throw '토큰 정보가 없습니다.';
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<SocialUserInfo?> _getUserInfo(String provider) async {
    switch (provider) {
      case 'google':
        return await _googleService.loginWithGoogle();
      case 'kakao':
        return await _kakaoService.loginWithKakao();
      case 'naver':
        return await _naverService.loginWithNaver();
      default:
        return null;
    }
  }

  Future<Response> _sendUserInfoToServer({
    required String provider,
    required String socialId,
    required String? email,
    required String? os,
    required String? deviceName
  }) async {
    try {
      return await _userAuthApi.sendUserInfo(
        provider: provider,
        socialId: socialId,
        email: email,
        os: os,
        deviceName: deviceName
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<String> findUsername({
    required String email
  }) async {
    try {
      final response = await _userAuthApi.findUsername(email: email);
      
      return response.data['data'];
    } catch (error) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword
  }) async {
    try {
      await _userAuthApi.changePassword(
        currentPassword: currentPassword, 
        newPassword: newPassword)
      ;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logoutCurrentDevice() async {
    try {
      final provider = await getProvider();
      await _userAuthApi.logoutCurrentDevice();
      await _logoutFromProvider(provider: provider);
      await deleteSecureInfo();
      await deleteUserInfo();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logoutTargetDevice({
    required String targetDeviceId
  }) async {
    try {
      await _userAuthApi.logoutTargetDevice(targetDeviceId: targetDeviceId);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _logoutFromProvider({
    String? provider
  }) async {
    if (provider == null) return;

    switch (provider) {
      case 'google':
        await _googleService.logout();
        break;
      case 'kakao':
        await _kakaoService.logout();
        break;
      case 'naver':
        await _naverService.logout();
        break;
    }
  }

  Future<void> deleteUser() async {
    try {
      final provider = await getProvider();
      await _userAuthApi.deleteUser();
      await _deleteUserFromProvider(provider: provider);
      await deleteSecureInfo();
      await deleteUserInfo();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _deleteUserFromProvider({
    String? provider
  }) async {
    if (provider == null) return;

    switch (provider) {
      case 'google':
        await _googleService.disconnect();
        break;
      case 'kakao':
        await _kakaoService.unlink();
        break;
      case 'naver':
        await _naverService.logoutAndDeleteToken();
        break;
    }
  }

  Future<void> reissueAccessToken() async {
    try {
      final response = await _userAuthApi.reissueAccessToken();
      final accessToken = _extractToken(response.headers['authorization'], 'Bearer ');

      if (accessToken != null) {
        await _saveAccessTokens(accessToken: accessToken);
      } else {
        throw '토큰 정보가 없습니다.';
      }

    } catch (error) {
      rethrow;
    }
  }

  String? _extractToken(List<String>? header, String prefix) {
    if (header == null || header.isEmpty) return null;
    return header.first.replaceFirst(prefix, '');
  }

  String? _extractCookie(List<String>? cookies, int index) {
    if (cookies == null || cookies.length <= index) return null;
    final cookieParts = cookies[index].split(';').first.split('=');
    return cookieParts.length > 1 ? cookieParts[1] : null;
  }

  Future<void> saveSecureInfo({
    required String accessToken,
    required String refreshToken,
    required String deviceId
  }) async {
    await _saveAccessTokens(accessToken: accessToken);
    await _saveRefreshToken(refreshToken: refreshToken);
    await _saveDeviceId(deviceId: deviceId);
  }

  Future<void> saveUserInfo({
    required String nickname,
    required String email,
    required String? provider,
    required bool isAutoLogin,
  }) async {
    await saveNickname(nickname: nickname);
    await _saveEmail(email: email);
    await _saveProvider(provider: provider ?? '');
    await _saveAutoLogin(isAutoLogin: isAutoLogin);
  }

  Future<void> _saveAccessTokens({
    required String accessToken,
  }) async {
    await _storage.write(key: 'accessToken', value: accessToken);
  }

  Future<void> _saveRefreshToken({
    required String refreshToken,
  }) async {
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> _saveDeviceId({
    required String deviceId
  }) async {
    await _storage.write(key: 'deviceId', value: deviceId);
  }

  Future<void> saveNickname({
    required String nickname
  }) async {
    await _sharedPreferences.setString('nickname', nickname);
  }

  Future<void> _saveEmail({
    required String email
  }) async {
    await _sharedPreferences.setString('email', email);
  }

  Future<void> _saveProvider({
    required String provider,
  }) async {
    await _sharedPreferences.setString('provider', provider);
  }

  Future<void> _saveAutoLogin({
    required bool isAutoLogin,
  }) async {
    await _sharedPreferences.setBool('isAutoLogin', isAutoLogin);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  Future<String?> getNickname() async {
    return _sharedPreferences.getString('nickname');
  }

  Future<String?> getEmail() async {
    return _sharedPreferences.getString('email');
  }

  Future<String?> getProvider() async {
    return _sharedPreferences.getString('provider');
  }

  Future<bool> getAutoLogin() async {
    return _sharedPreferences.getBool('isAutoLogin') ?? false;
  }

  Future<void> deleteSecureInfo() async {
    await _deleteAccessToken();
    await _deleteRefreshToken();
    await _deleteDeviceId();
  }

  Future<void> deleteUserInfo() async {
    await _deleteNickname();
    await _deleteEmail();
    await _deleteProvider();
    await _deleteAutoLogin();
  }

  Future<void> _deleteAccessToken() async {
    await _storage.delete(key: 'accessToken');
  }

  Future<void> _deleteRefreshToken() async {
    await _storage.delete(key: 'refreshToken');
  }

  Future<void> _deleteDeviceId() async {
    await _storage.delete(key: 'deviceId');
  }

  Future<void> _deleteNickname() async {
    await _sharedPreferences.remove('nickname');
  }

  Future<void> _deleteEmail() async {
    await _sharedPreferences.remove('email');
  }

  Future<void> _deleteProvider() async {
    await _sharedPreferences.remove('provider');
  }

  Future<void> _deleteAutoLogin() async {
    await _sharedPreferences.remove('isAutoLogin');
  }
}
