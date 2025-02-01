import 'package:dio/dio.dart';

import 'package:client_flutter/api/api.dart';

class UserApi {
  Future<Response> registerUser({
    required String username,
    required String password,
    required String nickname,
    required String email
  }) async {
    try {
      return await Api.dio.post(
        '/user/register',
        data: {
          'username': username,
          'password': password,
          'nickname': nickname,
          'email': email
        }
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> isUsernameTaken({
    required String username
  }) async {
    try {
      return await Api.dio.get(
        '/user/is-username-taken',
        queryParameters: {
          'username': username
        }
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> isNicknameTaken({
    required String nickname
  }) async {
    try {
      return await Api.dio.get(
        '/user/is-nickname-taken',
        queryParameters: {
          'nickname': nickname
        }
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUserInfo() async {
    try {
      return await Api.dio.get(
        '/user/profile',
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> changeNickname({
    required String nickname
  }) async {
    try {
      return await Api.dio.put(
        '/user/change-nickname',
        data: nickname
      );
    } catch (error) {
      rethrow;
    }
  }
}
