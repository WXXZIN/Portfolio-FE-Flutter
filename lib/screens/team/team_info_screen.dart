import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:client_flutter/models/team.dart';
import 'package:client_flutter/screens/team/team_info_tab.dart';
import 'package:client_flutter/screens/team/team_task_tab.dart';
import 'package:client_flutter/screens/team/team_management_tab.dart';
import 'package:client_flutter/services/team/team_service.dart';

class TeamInfoScreen extends StatefulWidget {
  final Team teamInfo;
  final bool isTeamLeader;

  const TeamInfoScreen({
    super.key,
    required this.teamInfo,
    required this.isTeamLeader
  });

  @override
  State<TeamInfoScreen> createState() => _TeamInfoScreenState();
}

class _TeamInfoScreenState extends State<TeamInfoScreen> {
  late TeamService _teamService;

  int _selectedIndex = 0;

  final List<Widget?> _pages = [
    null, null, null,
  ];

  bool _taskListLoaded = false;
  bool _applicationListLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _teamService = context.read<TeamService>();
      _teamService.getTeamInfo(teamId: widget.teamInfo.id);
    });

    _pages[0] = _createPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.isTeamLeader ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            onTap: _onTabTapped,
            tabs: [
              const Tab(text: '상세 정보'),
              const Tab(text: '작업 관리'),
              if (widget.isTeamLeader) const Tab(text: '요청 관리'),
            ],
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages.map((page) => page ?? const SizedBox.shrink()).toList(),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (_pages[index] == null) {
      _pages[index] = _createPage(index);
    }

    if (index == 1 && !_taskListLoaded) {
      _teamService.getTeamTaskList(teamId: widget.teamInfo.id);
      _taskListLoaded = true;
    } else if (index == 2 && !_applicationListLoaded) {
      _teamService.getTeamApplicationList(teamId: widget.teamInfo.id);
      _applicationListLoaded = true;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _createPage(int index) {
    switch (index) {
      case 0:
        return Consumer<TeamService>(
          builder: (context, teamService, child) {
            return TeamInfoTab(teamInfo: teamService.selectedTeam ?? widget.teamInfo);
          },
        );
      case 1:
        return Consumer<TeamService>(
          builder: (context, teamService, child) {
            return TeamTaskTab(teamInfo: teamService.selectedTeam ?? widget.teamInfo);
          },
        );
      case 2:
        return widget.isTeamLeader 
          ? Consumer<TeamService>(
              builder: (context, teamService, child) {
                return TeamManagementTab(teamInfo: teamService.selectedTeam ?? widget.teamInfo);
              },
            )
          : const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}
