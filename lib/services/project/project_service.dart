import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import 'package:client_flutter/models/page.dart' as p;
import 'package:client_flutter/models/project.dart';
import 'package:client_flutter/api/project_api.dart';

class ProjectService with ChangeNotifier {
  final ProjectApi _projectApi = ProjectApi();

  List<Project> _projectList = [];
  List<Project> _searchResults = [];
  Project? _selectedProject;

  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;

  List<Project> get projectList => _projectList;
  List<Project> get searchResults => _searchResults;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  Future<void> writeProject({
    required String title,
    required String content,
    required int requireMemberCount,
    required String deadline,
    required int teamId,
    required List<String>? tags,
  }) async {
    try {
      await _projectApi.writeProject(
        title: title,
        content: content,
        requireMemberCount: requireMemberCount,
        deadline: deadline,
        teamId: teamId,
        tags: tags,
      );

      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> getProjectList({
    bool loadMore = false,
  }) async {
    if (_isLoading || (loadMore && !_hasMoreData)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final int nextPage = loadMore ? _currentPage : 0;

      final response = await _projectApi.getProjectList(
        page: nextPage + 1
      );

      final pageData = p.Page.fromJson(
        response.data['data'],
        (json) => Project.fromJson(json),
      );

      if (loadMore) {
        _projectList.addAll(pageData.content);
      } else {
        _projectList = pageData.content;
      }

      _currentPage = nextPage + 1;
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

  Future<void> getSearchedProjectList({
    String searchType = 'title',
    String searchKeyword = '',
    String sortBy = 'latest',
    bool loadMore = false,
  }) async {
    if (_isLoading || (loadMore && !_hasMoreData)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final int nextPage = loadMore ? _currentPage : 0;

      final response = await _projectApi.getSearchedProjectList(
        searchType: searchType,
        searchKeyword: searchKeyword,
        sortBy: sortBy,
        page: nextPage + 1,
      );

      final pageData = p.Page.fromJson(
        response.data['data'],
        (json) => Project.fromJson(json),
      );

      if (loadMore) {
        _searchResults.addAll(pageData.content);
      } else {
        _searchResults = pageData.content;
        _currentPage = 0;
      }

      _currentPage = nextPage + 1;
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

  Future<void> getProjectListIsHearted({bool loadMore = false}) async {
    if (_isLoading || (loadMore && !_hasMoreData)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final int nextPage = loadMore ? _currentPage : 0;

      final response = await _projectApi.getProjectListIsHearted(page: nextPage + 1);
      final pageData = p.Page.fromJson(
        response.data['data'],
        (json) => Project.fromJson(json),
      );

      if (loadMore) {
        _projectList.addAll(pageData.content);
      } else {
        _projectList = pageData.content;
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

  Future<void> getProjectInfo({required int projectId}) async {
    try {
      final response = await _projectApi.getProjectInfo(projectId: projectId);
      _selectedProject = Project.fromJson(response.data['data']);
      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future<void> editProject({
    required int projectId,
    required String title,
    required String content,
    required int requireMemberCount,
    required String deadline,
    required List<String>? tags,
  }) async {
    try {
      await _projectApi.editProject(
        projectId: projectId,
        title: title,
        content: content,
        requireMemberCount: requireMemberCount,
        deadline: deadline,
        tags: tags,
      );

      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  Future <void> deleteProject({required int projectId}) async {
    try {
      await _projectApi.deleteProject(projectId: projectId);
      _projectList.removeWhere((project) => project.id == projectId);
      notifyListeners();
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.connectionError) {
         
      } else {
        rethrow;
      }
    }
  }

  void clearProjectList() {
    _currentPage = 0;
    _hasMoreData = true;
    notifyListeners();
  }

  void clearSearchResults() {
    _currentPage = 0;
    _hasMoreData = true;
    _searchResults = [];
    notifyListeners();
  }
}
