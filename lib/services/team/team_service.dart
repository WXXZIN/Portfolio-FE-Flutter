import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import 'package:client_flutter/api/team_api.dart';
import 'package:client_flutter/api/team_application_api.dart';
import 'package:client_flutter/api/team_task_api.dart';
import 'package:client_flutter/models/page.dart' as p;
import 'package:client_flutter/models/team.dart';
import 'package:client_flutter/models/team_application.dart';
import 'package:client_flutter/models/team_task.dart';

class TeamService with ChangeNotifier {
  final TeamApi _teamApi = TeamApi();
  final TeamApplicationApi _teamApplicationApi = TeamApplicationApi();
  final TeamTaskApi _teamTaskApi = TeamTaskApi();

  List<Team> _teamList = [];
  Team? _selectedTeam;

  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;

  List<TeamApplication> _teamApplicationList = [];
  List<TeamTask> _teamTaskList = [];
  TeamTask? _selectedTeamTask;

  List<Team> get teamList => _teamList;
  Team? get selectedTeam => _selectedTeam;
  List<TeamApplication> get teamApplicationList => _teamApplicationList;
  List<TeamTask> get teamTaskList => _teamTaskList;
  TeamTask? get selectedTeamTask => _selectedTeamTask;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  /* TeamService */

  Future<void> createTeam({
    required String name
  }) async {
    try {
      await _teamApi.createTeam(
        name: name
      );
      await getTeamList();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> getTeamList() async {
    try {
      final response = await _teamApi.getTeamList();
      List<dynamic> data = response.data['data'];

      _teamList = data.map((item) => Team.fromJson(item)).toList();
      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> getTeamInfo({
    required int teamId,
  }) async {
    try {
      final response = await _teamApi.getTeamInfo(teamId: teamId);

      _selectedTeam = Team.fromJson(response.data['data']);
      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> changeLeader({
    required int teamId,
    required String newLeaderName
  }) async {
    try {
      await _teamApi.changeLeader(
        teamId: teamId,
        newLeaderName: newLeaderName
      );
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> leaveTeam({
    required int teamId,
  }) async {
    try {
      await _teamApi.leaveTeam(teamId: teamId);
      await getTeamList();

      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  /* TeamApplicationService */

  Future<void> applyTeamApplication({
    required int teamId,
  }) async {
    try {
      await _teamApplicationApi.applyTeamApplication(teamId: teamId);
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> getTeamApplicationList({
    bool loadMore = false,
    required int teamId,
    String applicationStatus = ''
  }) async {
    if (_isLoading || (loadMore && !_hasMoreData)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final int nextPage = loadMore ? _currentPage : 0;

      final response = await _teamApplicationApi.getTeamApplicationList(
        teamId: teamId,
        applicationStatus: applicationStatus,
        page: nextPage + 1,
      );

      final pageData = p.Page.fromJson(
        response.data['data'],
        (json) => TeamApplication.fromJson(json),
      );

      if (loadMore) {
        _teamApplicationList.addAll(pageData.content);
      } else {
        _teamApplicationList = pageData.content;
      }

      _currentPage = pageData.pageNumber + 1;
      _hasMoreData = _currentPage < pageData.totalPages;
      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processApplication({
    required int teamId,
    required int applicationId,
    required String action
  }) async {
    try {
      if (action == 'approve') {
        final response = await _teamApplicationApi.processApplication(teamId: teamId, applicationId: applicationId, action: action);

        if (_selectedTeam != null) {
          final application = _teamApplicationList.firstWhere((app) => app.id == applicationId);
          _selectedTeam!.memberNames.add(application.nickname);
          _selectedTeam!.memberCount++;
          _selectedTeam!.projectStatus = response.data['data']['projectStatus'];
          _teamApplicationList.remove(application);
        }
      } else if (action == 'reject') {
        await _teamApplicationApi.processApplication(teamId: teamId, applicationId: applicationId, action: action);
        _teamApplicationList.removeWhere((app) => app.id == applicationId);
      }

      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> cancelTeamApplication({
    required int teamId,
  }) async {
    try {
      await _teamApplicationApi.cancelTeamApplication(teamId: teamId);
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  /* TeamTaskService */

  Future<void> addTeamTask({
    required String title,
    required String description,
    required String deadline,
    required int taskPriority,
    required int teamId,
    required String? assigneeMemberName
  }) async {
    try {
      await _teamTaskApi.addTeamTask(
        title: title,
        description: description,
        deadline: deadline,
        taskPriority: taskPriority,
        teamId: teamId,
        assigneeMemberName: assigneeMemberName
      );

      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> getTeamTaskList({
    bool loadMore = false,
    String taskStatus = 'TODO',
    required int teamId,
  }) async{
    if (_isLoading || (loadMore && !_hasMoreData)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final int nextPage = loadMore ? _currentPage : 0;

      final response = await _teamTaskApi.getTeamTaskList(
        teamId: teamId,
        taskStatus: taskStatus,
        page: nextPage + 1
      );

      final pageData = p.Page.fromJson(
        response.data['data'],
        (json) => TeamTask.fromJson(json),
      );

      if (loadMore) {
        _teamTaskList.addAll(pageData.content);
      } else {
        _teamTaskList = pageData.content;
      }

      _currentPage = pageData.pageNumber + 1;
      _hasMoreData = _currentPage < pageData.totalPages;
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTeamTaskInfo({
    required int teamId,
    required int taskId,
  }) async {
    try {
      final response = await _teamTaskApi.getTeamTaskInfo(
        teamId: teamId,
        taskId: taskId
      );

      _selectedTeamTask = TeamTask.fromJson(response.data['data']);
      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> editTeamTask({
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
      await _teamTaskApi.editTeamTask(
        teamId: teamId,
        taskId: taskId,
        title: title,
        description: description,
        deadline: deadline,
        taskStatus: taskStatus,
        taskPriority: taskPriority,
        assigneeMemberName: assigneeMemberName
      );

      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> deleteTeamTask({
    required int teamId,
    required int taskId,
  }) async {
    try {
      await _teamTaskApi.deleteTeamTask(
        teamId: teamId,
        taskId: taskId
      );

      _teamTaskList.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  void clearTeamList() {
    _selectedTeam = null;
    _teamList.clear();
    notifyListeners();
  }

  void clearTeamApplicationList() {
    _currentPage = 0;
    _hasMoreData = true;
    _teamApplicationList.clear();
    notifyListeners();
  }

  void clearTeamTaskList() {
    _currentPage = 0;
    _hasMoreData = true;
    _teamTaskList.clear();
    notifyListeners();
  }
}
