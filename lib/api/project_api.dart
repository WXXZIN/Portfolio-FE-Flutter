import 'package:dio/dio.dart';

import 'package:client_flutter/api/api.dart';

class ProjectApi {
  Future<Response> writeProject({
    required String title,
    required String content,
    required int requireMemberCount,
    required String deadline,
    required int teamId,
    required List<String>? tags,
  }) async {
    try {
      return await Api.dio.post(
        '/project',
        data: {
          'title': title,
          'content': content,
          'requireMemberCount': requireMemberCount,
          'deadline': deadline,
          'teamId': teamId,
          'tags': tags,
        },
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getProjectList({
    int page = 1
  }) async {
    try {
      return await Api.dio.get(
        '/project',
        queryParameters: {
          'page': page
        },
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getSearchedProjectList({
    required String searchType,
    required String searchKeyword,
    String? sortBy,
    int page = 1,
  }) async {
    try {
      return await Api.dio.get(
        '/project/search',
        queryParameters: {
          'searchType': searchType,
          'searchKeyword': searchKeyword,
          'sortBy': sortBy,
          'page': page,
        },
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getProjectListIsHearted({
    int page = 1
  }) async {
    try {
      return await Api.dio.get(
        '/project/hearted',
        queryParameters: {
          'page': page,
        },
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getProjectInfo({
    required int projectId,
  }) async {
    try {
      return await Api.dio.get('/project/$projectId');
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> editProject({
    required int projectId,
    required String title,
    required String content,
    required int requireMemberCount,
    required String deadline,
    required List<String>? tags,
  }) async {
    try {
      return await Api.dio.put(
        '/project/$projectId',
        data: {
          'title': title,
          'content': content,
          'requireMemberCount': requireMemberCount,
          'deadline': deadline,
          'tags': tags,
        },
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteProject({
    required int projectId
  }) async {
    try {
      return await Api.dio.delete('/project/$projectId');
    } catch (error) {
      rethrow;
    }
  }
}
