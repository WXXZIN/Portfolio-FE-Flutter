import 'dart:async';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import 'package:client_flutter/models/user.dart';
import 'package:client_flutter/services/user/user_service.dart';
import 'package:client_flutter/services/auth/user_auth_service.dart';
import 'package:client_flutter/utils/jwt_util.dart';

class AuthProvider with ChangeNotifier, WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _isAutoLogin = false;
  User? _user;
  final UserAuthService _userAuthService;
  final UserService _userService;

  Timer? _tokenRefreshTimer;

  Function? onLogin;
  Function? onLogout;

  bool get isAuthenticated => _isAuthenticated;
  bool get isAutoLogin => _isAutoLogin;
  User? get user => _user;
  UserAuthService get userAuthService => _userAuthService;

  AuthProvider({
    required UserAuthService userAuthService,
    UserService? userService,
  })  : _userAuthService = userAuthService,
        _userService = userService ?? UserService() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initializeAuthProvider() async {
    await _loadUserInfo();
    await _checkAuthStatus();
  }

  Future<void> _loadUserInfo() async {
    final nickname = await _userAuthService.getNickname();
    final email = await _userAuthService.getEmail();
    final provider = await _userAuthService.getProvider();

    if (nickname != null && email != null && provider != null) {
      _user = User(nickname: nickname, email: email, provider: provider);
    }
  }

  Future<void> _checkAuthStatus() async {
    final accessToken = await _userAuthService.getAccessToken();
    final refreshToken = await _userAuthService.getRefreshToken();
    _isAutoLogin = await _userAuthService.getAutoLogin() == true;

    if (accessToken != null && refreshToken != null) {
      bool isTokenValid = await verifyToken();

      if (isTokenValid) {
        if (_isAutoLogin) {
          _isAuthenticated = true;
          _startTokenRefreshTimer();
        } else {
          await logoutCurrentDevice();
        }
      } else {
        if (_isAutoLogin) {
          await reissueAccessToken();
        } else {
          await logoutCurrentDevice();
        }
      }
    }

    notifyListeners();
  }

  Future<bool> verifyToken() async {
    try {
      final User? userInfo = await _userService.getUserInfo();
      _user = userInfo;
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> localLogin({
    required String username,
    required String password,
    required bool isAutoLogin,
  }) async {
    try {
      _isAutoLogin = isAutoLogin;

      final User userInfo = await _userAuthService.localLogin(
        username: username,
        password: password,
        isAutoLogin: isAutoLogin,
      );

      _user = userInfo;
      _isAuthenticated = true;
      _startTokenRefreshTimer();

      if (onLogin != null) {
        onLogin!();
      }

      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> socialLogin({
    required String provider,
  }) async {
    try {
      final User? userInfo = await _userAuthService.socialLogin(provider: provider);

      if (userInfo == null) {
        return;
      }

      _user = userInfo;
      _isAuthenticated = true;
      _startTokenRefreshTimer();

      if (onLogin != null) {
        onLogin!();
      }

      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else if (error is Exception && error.toString().contains('naver login timeout')) {
         debugPrint(error.toString());
      } else {
        rethrow;
      }
    }
  }

  Future<void> logoutCurrentDevice() async {
    try {
      await _userAuthService.logoutCurrentDevice().then((_) {
        _clearUserInfo();
      });
      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> logoutTargetDevice({
    required String targetDeviceId,
  }) async {
    try {
      await _userAuthService.logoutTargetDevice(targetDeviceId: targetDeviceId);
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> deleteUser() async {
    try {
      await _userAuthService.deleteUser().then((_) {
        _clearUserInfo();
      });
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> reissueAccessToken() async {
    try {
      await _userAuthService.reissueAccessToken();
      _isAuthenticated = true;
      _startTokenRefreshTimer();
      notifyListeners();
    } catch (error) {
      await logoutCurrentDevice();
    }
  }

  Future<void> updateUser({
    required String nickname,
  }) async {
    try {
      await _userAuthService.saveNickname(nickname: nickname);
      _user = User(nickname: nickname, email: _user!.email, provider: _user!.provider);
      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  void _clearUserInfo() {
    _user = null;
    _isAuthenticated = false;
    _stopTokenRefreshTimer();

    onLogout?.call();
  }

  void _startTokenRefreshTimer() async {
    if (_tokenRefreshTimer != null && _tokenRefreshTimer!.isActive) {
      return;
    }

    final accessToken = await _userAuthService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    final expirationTime = JwtUtil.getExpirationTime(accessToken.toString());
    final timeToExpiration = expirationTime.difference(DateTime.now()).inMinutes;

    if (timeToExpiration <= 1) {
      await reissueAccessToken();
    } else {
      final refreshTime = timeToExpiration > 1 ? timeToExpiration - 1 : 0;

      _tokenRefreshTimer?.cancel();
      _tokenRefreshTimer = Timer(Duration(minutes: refreshTime), () {
        reissueAccessToken().then((_) {
          _startTokenRefreshTimer();
        });
      });
    }
  }

  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
  }

  @override
  void dispose() {
    _stopTokenRefreshTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
