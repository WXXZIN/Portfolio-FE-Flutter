import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:client_flutter/api/api.dart';

class UserAuthApi {
  Future<Response> localLogin({
    required String username,
    required String password,
    required String? os,
    required String? deviceName
  }) async {
    try {
      return await Api.dio.post(
        '/user/auth/login',
        options: Options(
          headers: {
            'os': os,
            'deviceName': deviceName
          },
        ),
        data: jsonEncode({
          'username': username,
          'password': password
        }),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> sendUserInfo({
    required String provider,
    required String socialId,
    required String? email,
    required String? os,
    required String? deviceName
  }) async {
    try {
      return await Api.dio.post(
        '/user/auth/sdk/oauth2/$provider',
        options: Options(
          headers: {
            'os': os,
            'deviceName': deviceName
          },
        ),
        data: jsonEncode({
          'socialId': socialId,
          'email': email
        }),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> findUsername({
    required String email,
  }) async {
    try {
      return await Api.dio.post(
        '/user/auth/find-username',
        data: email,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await Api.dio.put(
        '/user/auth/change-password',
        data: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword
        }),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> logoutCurrentDevice() async {
    try {
      return await Api.dio.post(
        '/user/auth/logout',
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> logoutTargetDevice({
    required String targetDeviceId
  }) async {
    try {
      return await Api.dio.post(
        '/user/auth/logout/$targetDeviceId',
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteUser() async {
    try {
      return await Api.dio.delete(
        '/user/auth/delete'
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> reissueAccessToken() async {
    try {
      return await Api.dio.post(
        '/user/auth/reissue'
      );
    } catch (error) {
      rethrow;
    }
  }
}
