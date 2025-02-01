import 'package:dio/dio.dart';

import 'package:client_flutter/api/api.dart';

class TeamTaskApi {
  Future<Response> addTeamTask({
    required String title,
    required String description,
    required String deadline,
    required int taskPriority,
    required int teamId,
    required String? assigneeMemberName
  }) async {
    try {
      return await Api.dio.post(
        '/team/$teamId/task',
        data: {
          'title': title,
          'description': description,
          'deadline': deadline,
          'taskPriority': taskPriority,
          'assigneeMemberName': assigneeMemberName
        },
      );
    } catch (error) {
      rethrow;
    }
  }
  
  Future<Response> getTeamTaskList({
    required int teamId,
    required taskStatus,
    int page = 1
  }) async {
    try {
      return await Api.dio.get(
        '/team/$teamId/task',
        queryParameters: {
          'taskStatus': taskStatus,
          'page': page
        },
      ); 
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getTeamTaskInfo({
    required int teamId,
    required int taskId,
  }) async {
    try {
      return await Api.dio.get(
        '/team/$teamId/task/$taskId',
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> editTeamTask({
    required int teamId,
    required int taskId,
    required String title,
    required String description,
    required String deadline,
    required String taskStatus,
    required int taskPriority,
    required String? assigneeMemberName
  }) async {
    try {
      return await Api.dio.put(
        '/team/$teamId/task/$taskId',
        data: {
          'title': title,
          'description': description,
          'deadline': deadline,
          'taskStatus': taskStatus,
          'taskPriority': taskPriority,
          'assigneeMemberName': assigneeMemberName
        },
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteTeamTask({
    required int teamId,
    required int taskId,
  }) async {
    try {
      return await Api.dio.delete(
        '/team/$teamId/task/$taskId',
      );
    } catch (error) {
      rethrow;
    }
  }
}