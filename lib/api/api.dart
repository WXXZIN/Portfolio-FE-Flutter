import 'package:client_flutter/providers/network_status_provider.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:client_flutter/services/logging/logging_service.dart';
import 'package:provider/provider.dart';

class Api {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.wxxzin.org/api/v1',
      // baseUrl: 'http://192.168.1.106:8080/api/v1',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client-Type': 'FLUTTER-APP'
      },
    ),
  );
  
  static Dio get dio => _dio;

  static void addInterceptor(BuildContext context) {
    final networkStatusProvider = context.read<NetworkStatusProvider>();

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final FlutterSecureStorage storage = FlutterSecureStorage();
        final accessToken = await storage.read(key: "accessToken");
        final refreshToken = await storage.read(key : "refreshToken");
        final deviceId = await storage.read(key: "deviceId");

        if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
        }
        
        String cookie = '';

        if (deviceId != null) {
          cookie += 'deviceId=$deviceId';
        }

        if (options.path == '/user/auth/logout' ||
            options.path.startsWith('/user/auth/logout/') ||
            options.path == '/user/auth/reissue') {
          cookie += '; refreshToken=$refreshToken';
        }

        options.headers['Cookie'] = cookie;

        return handler.next(options);
      },
      onResponse: (response, handler) {
        networkStatusProvider.updateApiReachable(true);

        return handler.next(response);
      },
      onError: (DioException error, handler) {
        if (error.type == DioExceptionType.connectionError) {
          networkStatusProvider.updateApiReachable(false);
        }

        if (error.response != null) {
          networkStatusProvider.updateApiReachable(true);

          String message = 'An unexpected error occurred';

          final status = error.response?.statusCode;
          final data = error.response?.data;
          final errorDetails = data?['errorDetails'];
          final errorType = errorDetails?['errorType'];
          final detailMessage = errorDetails?['detailMessage'];

          switch (status) {
            case 400:
              message += 'Bad Request: $errorType - $detailMessage';
              break;
            case 401:
              message += 'Unauthorized: $errorType - $detailMessage';
              break;
            case 403:
              message += 'Forbidden: $errorType - $detailMessage';
              break;
            case 404:
              message += 'Not Found: $errorType - $detailMessage';
              break;
            case 500:
              message += 'Internal Server Error: $errorType - $detailMessage';
              break;
            default:
              message += 'Unknown Error: $errorType - $detailMessage';
              break;
          }

          LoggerService.logger.e(message);

          throw DioException(
            requestOptions: error.requestOptions,
            type: DioExceptionType.badResponse,
            error: errorType,
            message: detailMessage
          );
        }

        return handler.next(error);
      }
    ));
  }
}
