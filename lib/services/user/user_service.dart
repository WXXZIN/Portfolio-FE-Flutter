import 'package:dio/dio.dart';

import 'package:client_flutter/api/user_api.dart';
import 'package:client_flutter/models/user.dart';

class UserService {
  final UserApi _userApi = UserApi();

  Future<void> registerUser({
    required String username,
    required String password,
    required String nickname,
    required String email,
  }) async {
    try {
      await _userApi.registerUser(
        username: username,
        password: password,
        nickname: nickname,
        email: email,
      );
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<bool> isUsernameTaken({
    required String username,
  }) async {
    try {
      final response = await _userApi.isUsernameTaken(username: username);

      return response.data['data'];
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
        return false;
      } else {
        rethrow;
      }
    }
  }

  Future<bool> isNicknameTaken({
    required String nickname,
  }) async {
    try {
      final response = await _userApi.isNicknameTaken(nickname: nickname);

      return response.data['data'];
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         return false;
      } else {
        rethrow;
      }
    }
  }

  Future<User?> getUserInfo() async {
    try {
      final response = await _userApi.getUserInfo();

      return User.fromJson(response.data['data']);
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         return null;
      } else {
        rethrow;
      }
    }
  }

  Future<void> changeNickname({
    required String nickname,
  }) async {
    try {
      await _userApi.changeNickname(nickname: nickname);
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }
}
