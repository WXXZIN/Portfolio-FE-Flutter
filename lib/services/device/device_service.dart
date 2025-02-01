import 'dart:io';

import 'package:dio/dio.dart';

import 'package:client_flutter/api/user_device_api.dart';
import 'package:client_flutter/models/device.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  final UserDeviceApi _deviceApi;
  final DeviceInfoPlugin _deviceInfo;

  DeviceService({
    UserDeviceApi? deviceApi,
    DeviceInfoPlugin? deviceInfo
  }) : 
    _deviceApi = deviceApi ?? UserDeviceApi(),
    _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  Future<Map<String, List<Device>>> getDeviceList() async {
    try {
      final response = await _deviceApi.getDeviceList();
      Map<String, dynamic> data = response.data['data'];
      
      return data.map(
        (key, value) => MapEntry(
          key, 
          (value as List).map((item) => Device.fromJson(item)).toList()
        )
      );
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         return {};
      } else {
        rethrow;
      }
    }
  }

  Future<Device?> getDeviceDetail(String deviceId) async {
    try {
      final response = await _deviceApi.getDeviceDetail(deviceId: deviceId);
      
      return Device.fromJson(response.data['data']);
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         return null;
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, String?>> getDeviceInfo() async {
    Map<String, String?> deviceDetails = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;

        deviceDetails['model'] = 'Android';
        deviceDetails['deviceName'] = androidInfo.device;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceDetails['model'] = iosInfo.model;
        deviceDetails['deviceName'] = iosInfo.name;
      } else {
        throw UnsupportedError("지원하지 않는 플랫폼입니다.");
      }
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }

    return deviceDetails;
  }
}
