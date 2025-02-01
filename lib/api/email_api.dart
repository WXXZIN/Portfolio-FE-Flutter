import 'package:dio/dio.dart';

import 'package:client_flutter/api/api.dart';

class EmailApi {
  Future<Response> sendCertificationEmail({
    required String email
  }) async {
    try {
      return await Api.dio.post(
        '/email/certification',
        data: email
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> sendTemporayPasswordEmail({
    required String username,
    required String email,
  }) async {
    try {
      return await Api.dio.post(
        '/email/temporary-password',
        data: {
          'username': username,
          'email': email
        }
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> checkCertificationNumber({
    required String email,
    required String certificationNumber
  }) async {
    try {
      return await Api.dio.post(
        '/email/check-certification',
        data: {
          'email': email,
          'certificationNumber': certificationNumber
        }
      );
    } catch (error) {
      rethrow;
    }
  }
}
