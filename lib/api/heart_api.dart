import 'package:dio/dio.dart';

import 'package:client_flutter/api/api.dart';

class HeartApi {
  Future<Response> heartProject({
    required int projectId,
  }) async {
    try {
      return await Api.dio.post(
        '/project/heart/$projectId',
      );
    } catch (error) {
      rethrow;
    }
  }
}
