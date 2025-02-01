import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/models/project.dart';
import 'package:client_flutter/screens/main/main_screen.dart';
import 'package:client_flutter/services/project/project_service.dart';
import 'package:client_flutter/widgets/project_status_badge.dart';

class ProjectList extends StatefulWidget {
  final List<Project> projectList;
  final String? searchType;
  final String? searchKeyword;
  final String? sortBy;

  const ProjectList({
    super.key, 
    required this.projectList,
    this.searchType,
    this.searchKeyword,
    this.sortBy,
  });

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  late ProjectService _projectService;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _projectService = context.read<ProjectService>();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _projectService.isLoading;

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.searchType != null) {
          await _projectService.getSearchedProjectList(
            searchType: widget.searchType!,
            searchKeyword: widget.searchKeyword!,
            sortBy: widget.sortBy!,
          );
        } else {
          _projectService.clearProjectList();
          await _projectService.getProjectList();
        }
      },
      child: widget.projectList.isEmpty && !isLoading
          ? ListView(
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 200.0),
                    child: Text('프로젝트가 없습니다.'),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: widget.projectList.length + (_projectService.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < widget.projectList.length) {
                    final project = widget.projectList[index];
                    final List<String> tags = List<String>.from(project.tags ?? []);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () async {
                          try {
                            await _projectService.getProjectInfo(projectId: project.id);

                            setState(() {
                              widget.projectList[index].viewCount++;
                            });

                            context.push(
                              '/project/${project.id}',
                              extra: {'projectInfo': _projectService.selectedProject},
                            );
                          } on DioException catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.message!)),
                            );
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ProjectStatusBadge(status: project.recruitmentStatus),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Icon(Icons.remove_red_eye, color: Colors.grey.shade600, size: 16.0),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          project.viewCount.toString(),
                                          style: const TextStyle(fontSize: 12.0),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Icon(Icons.favorite, color: Colors.red.shade600, size: 16.0),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          project.heartCount.toString(),
                                          style: const TextStyle(fontSize: 12.0),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  project.title,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  project.content,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12.0),
                                if (tags.isNotEmpty)
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: tags.map((tag) {
                                      return InkWell(
                                        onTap: () {
                                          MainScreen.mainScreenKey.currentState?.switchToSearchTab(tag);
                                        },
                                        child: Text(
                                          '#$tag',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_projectService.isLoading && _projectService.hasMoreData) {
        if (widget.searchType != null) {
          _projectService.getSearchedProjectList(
            searchType: widget.searchType!,
            searchKeyword: widget.searchKeyword!,
            sortBy: widget.sortBy ?? 'date',
            loadMore: true,
          );
        } else {
          _projectService.getProjectList(loadMore: true);
        }
      }
    }
  }
}
