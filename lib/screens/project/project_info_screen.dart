import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/models/project.dart';
import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/screens/main/main_screen.dart';
import 'package:client_flutter/screens/project/edit_project_screen.dart';
import 'package:client_flutter/services/project/heart_service.dart';
import 'package:client_flutter/services/project/project_service.dart';
import 'package:client_flutter/services/team/team_service.dart';
import 'package:client_flutter/widgets/custom_dialog.dart';

// ignore: must_be_immutable
class ProjectInfoScreen extends StatefulWidget {
  Project projectInfo;
  final bool isTeamMember;

  ProjectInfoScreen({
    super.key, 
    required this.projectInfo,
    required this.isTeamMember,
  });

  @override
  State<ProjectInfoScreen> createState() => _ProjectInfoScreenState();
}

class _ProjectInfoScreenState extends State<ProjectInfoScreen> {
  late AuthProvider _authProvider;
  final HeartService _heartService = HeartService();

  late bool isHearted;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    isHearted = widget.projectInfo.isHearted;
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = _authProvider.isAuthenticated;

    final tags = widget.projectInfo.tags;
    final isAuthor = _authProvider.user?.nickname == widget.projectInfo.writerName;

    return PopScope(
      onPopInvokedWithResult: (result, data) async {
        _onWillPop(result, data);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (isAuthor)
              PopupMenuButton<String>(
                color: Colors.white,
                icon: const Icon(Icons.more_vert),
                onSelected: (String result) {
                  switch (result) {
                    case 'handleEdit':
                      _handleEdit();
                      break;
                    case 'handleDelete':
                      _handleDelete();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'handleEdit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('수정'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'handleDelete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('삭제'),
                      ],
                    ),
                  ),
                ],
              )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Divider(height: 1, thickness: 1, color: Colors.grey[300]),
              _buildprojectInfos(tags ?? []),
              _buildProjectIntroduction(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(isAuthenticated, widget.isTeamMember),
      ),
    );
  }

  Future<void> _handleEdit() async {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      barrierColor: Colors.white,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return EditProjectScreen(projectInfo: widget.projectInfo);
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          widget.projectInfo = result;
        });

        final projectService = context.read<ProjectService>();

        projectService.clearProjectList();
        projectService.getProjectList();
      }
    });
  }

  Future<void> _handleDelete() async {
    final shouldDelete = await showCustomDialog(
      context,
      '프로젝트를 삭제하시겠습니까?',
      () => Navigator.of(context).pop(false),
      () => Navigator.of(context).pop(true),
    );
    
    if (shouldDelete == true) {
      try {
        final projectService = context.read<ProjectService>();
        await projectService.deleteProject(projectId: widget.projectInfo.id);
        Navigator.of(context).pop();
      } on DioException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message!)),
        );
      }
    }
  }

  void _handleLike() {
    setState(() {
      isHearted = !isHearted;
      if (isHearted) {
        widget.projectInfo.heartCount++;
      } else {
        widget.projectInfo.heartCount--;
      }
    });
  }

  Future<void> _handleApply() async {
    try {
      final teamService = context.read<TeamService>();
      await teamService.applyTeamApplication(teamId: widget.projectInfo.teamId);
      setState(() {
        widget.projectInfo.isApplied = true;
      });
    } on DioException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message!)),
      );
    }
  }

  Future<void> _handleCancelApply() async {
    try {
      final teamService = context.read<TeamService>();
      await teamService.cancelTeamApplication(teamId: widget.projectInfo.teamId);
      setState(() {
        widget.projectInfo.isApplied = false;
      });
    } on DioException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message!)),
      );
    }
  }

  Future<void> _handleSendHeartRequest() async {
    try {
      await _heartService.heartProject(projectId: widget.projectInfo.id);

      final projectService = context.read<ProjectService>();

      projectService.clearProjectList();
      projectService.getProjectList();
    } on DioException {
      setState(() {
        isHearted = !isHearted;
        if (isHearted) {
          widget.projectInfo.heartCount++;
        } else {
          widget.projectInfo.heartCount--;
        }
      });
    }
  }

  Future<void> _onWillPop(bool result, dynamic data) async {
    if (isHearted != widget.projectInfo.isHearted) {
      await _handleSendHeartRequest();
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.projectInfo.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '작성자: ${widget.projectInfo.writerName}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildIconText(Icons.access_time, widget.projectInfo.createdAt),
              const SizedBox(width: 16),
              _buildIconText(Icons.remove_red_eye, '${widget.projectInfo.viewCount}'),
              const SizedBox(width: 16),
              _buildIconText(Icons.favorite, '${widget.projectInfo.heartCount}', color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildprojectInfos(List<String> tags) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProjectInfo('모집 인원', '${widget.projectInfo.requireMemberCount}명'),
              _buildProjectInfo('마감일', widget.projectInfo.deadline),
              if (!tags.contains('')) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: tags.map((tag) {
                    return InkWell(
                      onTap: () {
                        MainScreen.mainScreenKey.currentState?.switchToSearchTab(tag);
                        Navigator.of(context).pop();
                      },
                      child: Chip(
                        label: Text('#$tag'),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: const TextStyle(color: Colors.blue),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectIntroduction() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '프로젝트 소개',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.projectInfo.content,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isAuthenticated, bool isTeamMember) {
    return BottomAppBar(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: isAuthenticated ? _handleLike : null,
              icon: Icon(
                isHearted ? Icons.favorite : Icons.favorite_border,
                color: isHearted ? Colors.red : null,
              ),
            ),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, 
                backgroundColor: Colors.black,
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isAuthenticated && !isTeamMember
                  ? widget.projectInfo.recruitmentStatus == '모집 중'
                      ? widget.projectInfo.isApplied
                          ? _handleCancelApply
                          : _handleApply
                      : null
                  : null,
              child: Text(widget.projectInfo.isApplied ? "지원 취소" : "바로 지원"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
