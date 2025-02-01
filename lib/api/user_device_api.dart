import 'package:dio/dio.dart';

import 'package:client_flutter/api/api.dart';

class UserDeviceApi {
  Future<Response> getDeviceList() async {
    try {
      return await Api.dio.get(
        '/user/device',
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getDeviceDetail({
    required String deviceId,
  }) async {
    try {
      return await Api.dio.get(
        '/user/device/$deviceId',
      );
    } catch (error) {
      rethrow;
    }
  }
}
