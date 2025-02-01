import 'package:dio/dio.dart';

import 'package:client_flutter/api/api.dart';

class TeamApplicationApi {
  Future<Response> applyTeamApplication({
    required int teamId,
  }) async {
    try {
      return await Api.dio.post(
        '/team/$teamId/application',
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getTeamApplicationList({
    required int teamId,
    String applicationStatus = '',
    int page = 1,
  }) async {
    try {
      return await Api.dio.get(
        '/team/$teamId/application',
        queryParameters: {
          'applicationStatus': applicationStatus,
          'page': page,
        },
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> processApplication({
    required int teamId,
    required int applicationId,
    required String action
  }) {
    return Api.dio.put(
      '/team/$teamId/application/$applicationId',
      queryParameters: {
        'action': action,
      },
    );
  }

  Future<Response> cancelTeamApplication({
    required int teamId,
  }) async {
    try {
      return await Api.dio.delete(
        '/team/$teamId/application',
      );
    } catch (error) {
      rethrow;
    }
  }
}
