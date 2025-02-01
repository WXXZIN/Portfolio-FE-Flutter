import 'package:dio/dio.dart';

import 'package:client_flutter/api/email_api.dart';

class EmailService {
  final EmailApi _emailApi = EmailApi();

  Future<void> sendCertificationEmail({
    required String email
  }) async {
    try {
      await _emailApi.sendCertificationEmail(email: email);
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> sendTemporayPasswordEmail({
    required String username,
    required String email,
  }) async {
    try {
      await _emailApi.sendTemporayPasswordEmail(username: username, email: email);
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> checkCertificationNumber({
    required String email,
    required String certificationNumber,
  }) async {
    try {
      await _emailApi.checkCertificationNumber(
        email: email,
        certificationNumber: certificationNumber,
      );
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }
}
