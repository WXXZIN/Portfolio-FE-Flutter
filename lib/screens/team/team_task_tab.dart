import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:client_flutter/models/team.dart';
import 'package:client_flutter/screens/team/add_team_task_screen.dart';
import 'package:client_flutter/services/team/team_service.dart';
import 'package:client_flutter/widgets/team_task_list.dart';

class TeamTaskTab extends StatefulWidget {
  final Team teamInfo;

  const TeamTaskTab({
    super.key,
    required this.teamInfo
  });

  @override
  State<TeamTaskTab> createState() => _TeamTaskTabState();
}

class _TeamTaskTabState extends State<TeamTaskTab> {
  late TeamService _teamService;
  late String _selectedTaskStatus;

  final List<String> _taskStatus = ['할 일', '완료'];
  final Map<String, String> _taskStatusMap = {
    '할 일': 'TODO',
    '완료': 'DONE',
  };

  @override
  void initState() {
    super.initState();
    _teamService = context.read<TeamService>();
    _selectedTaskStatus = _taskStatus.first;
  }

  @override
  Widget build(BuildContext context) {
    final teamService = context.watch<TeamService>();
    final teamTaskList = teamService.teamTaskList;

    return Scaffold(
      body: Column(
        children: [
          _buildStatusSelector(),
          _buildResultCount(teamTaskList.length),
          Expanded(
            child: TeamTaskList(
              teamTaskList: teamTaskList,
              teamInfo: widget.teamInfo,
            ),
          ),
        ],
      ),
    );
  }

  void _onSearch() {
    _teamService.clearTeamTaskList();
    _teamService.getTeamTaskList(
      taskStatus: _taskStatusMap[_selectedTaskStatus]!,
      teamId: widget.teamInfo.id,
    );
  }
  
  void _showAddTeamTaskScreen(
    TeamService teamService,
    int teamId, 
    List<String> memberNameList
  )  {
    if (memberNameList.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('팀원이 없습니다. 팀원을 추가해주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      barrierColor: Colors.white,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return AddTeamTaskScreen(
          teamId: teamId, 
          memberNameList: memberNameList,
        );
      },
    ).then((result) {
      if (result == true) {
        teamService.clearTeamTaskList();
        teamService.getTeamTaskList(teamId: teamId);
      }
    });
  }

  Widget _buildStatusSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 30,
            child: ToggleButtons(
              isSelected: _taskStatus.map((type) => type == _selectedTaskStatus).toList(),
              onPressed: (index) {
                setState(() {
                  _selectedTaskStatus = _taskStatus[index];
                });
                _onSearch();
              },

              borderRadius: BorderRadius.circular(8.0),
              
              children: _taskStatus.map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    type,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 25),
              onPressed: () {
                _showAddTeamTaskScreen(
                    _teamService, widget.teamInfo.id, widget.teamInfo.memberNames);
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCount(int resultCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총 $resultCount개 결과',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
