import 'package:dio/dio.dart';

import 'package:client_flutter/api/api.dart';

class TeamApi {
  Future<Response> createTeam({
    required String name
  }) async {
    try {
      return await Api.dio.post(
        '/team',
        data: {
          'name': name
        }
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getTeamList() async {
    try {
      return await Api.dio.get(
        '/team'
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getTeamInfo({
    required int teamId
  }) async {
    try {
      return await Api.dio.get(
        '/team/$teamId'
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> changeLeader({
    required int teamId,
    required String newLeaderName
  }) async {
    try {
      return await Api.dio.put(
        '/team/$teamId/change-leader',
        data: newLeaderName
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> leaveTeam({
    required int teamId
  }) async {
    try {
      return await Api.dio.delete(
        '/team/$teamId'
      );
    } catch (error) {
      rethrow;
    }
  }
}
