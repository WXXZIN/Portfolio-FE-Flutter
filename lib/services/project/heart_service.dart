import 'package:dio/dio.dart';

import 'package:client_flutter/api/heart_api.dart';

class HeartService {
  final HeartApi _heartApi = HeartApi();

  Future<void> heartProject({
    required int projectId,
  }) async {
    try {
      await _heartApi.heartProject(
        projectId: projectId,
      );
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }
}
