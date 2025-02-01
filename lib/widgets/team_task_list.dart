import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/models/team.dart';
import 'package:client_flutter/models/team_task.dart';
import 'package:client_flutter/screens/team/edit_team_task_screen.dart';
import 'package:client_flutter/services/team/team_service.dart';
import 'package:client_flutter/widgets/custom_dialog.dart';

class TeamTaskList extends StatefulWidget {
  final Team teamInfo;
  final List<TeamTask> teamTaskList;

  const TeamTaskList({
    super.key,
    required this.teamInfo,
    required this.teamTaskList,
  });

  @override
  State<TeamTaskList> createState() => _TeamTaskListState();
}

class _TeamTaskListState extends State<TeamTaskList> {
  late TeamService _teamService;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _teamService = context.read<TeamService>();
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
    final isLoading = _teamService.isLoading;
    
    return RefreshIndicator(
      onRefresh: () async {
        _teamService.clearTeamTaskList();
        await _teamService.getTeamTaskList(teamId: widget.teamInfo.id);
      },
      child: widget.teamTaskList.isEmpty && !isLoading
          ? ListView(
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 200.0),
                    child: Text('등록된 작업이 없습니다.'),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: widget.teamTaskList.length + (_teamService.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < widget.teamTaskList.length) {
                    final teamTask = widget.teamTaskList[index];

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: teamTask.getPriorityColor(),
                            radius: 10,
                          ),
                          title: Text(
                            teamTask.title,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                teamTask.description,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  teamTask.assigneeMemberName != '-'
                                      ? '담당자: ${teamTask.assigneeMemberName}'
                                      : '담당자: 미정',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (teamTask.taskStatus == 'TODO')...[
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _handleEditTask(
                                      _teamService,
                                      widget.teamInfo.id,
                                      widget.teamInfo.memberNames,
                                      teamTask,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _handleDeleteTask(teamTask.id);
                                  },
                                ),
                              ]
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
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

  Future<void> _handleEditTask(
    TeamService teamService,
    int teamId,
    List<String> memberNameList,
    TeamTask teamTask,
  ) async {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      barrierColor: Colors.white,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return EditTeamTaskScreen(
          teamId: teamId, 
          memberNameList: memberNameList,
          teamTask: teamTask
        );
      }
    ).then((result) {
      if (result == true) {
        teamService.clearTeamTaskList();
        teamService.getTeamTaskList(teamId: teamId);
      }
    });
  }

  Future<void> _handleDeleteTask(int taskId) async {
    final shouldProceed = await showCustomDialog(
      context, 
      '작업을 삭제하시겠습니까?', 
      () => Navigator.of(context).pop(false), 
      () => Navigator.of(context).pop(true),
    );

    if (shouldProceed == true) {
      try {
        await _teamService.deleteTeamTask(teamId: widget.teamInfo.id, taskId: taskId);
      } on DioException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message!)),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_teamService.isLoading && _teamService.hasMoreData) {
        _teamService.getTeamTaskList(loadMore: true, teamId: widget.teamInfo.id);
      }
    }
  }
}
