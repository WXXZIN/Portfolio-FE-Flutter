import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/models/team.dart';
import 'package:client_flutter/models/team_application.dart';
import 'package:client_flutter/services/team/team_service.dart';

class TeamManagementTab extends StatefulWidget {
  final Team teamInfo;

  const TeamManagementTab({
    super.key,
    required this.teamInfo
  });

  @override
  State<TeamManagementTab> createState() => _TeamManagementTabState();
}

class _TeamManagementTabState extends State<TeamManagementTab> {
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
        child: Consumer<TeamService>(
          builder: (context, teamService, child) {
            return RefreshIndicator(
              onRefresh: () async {
                teamService.clearTeamApplicationList();
                await teamService.getTeamApplicationList(teamId: widget.teamInfo.id);
              },
              child: teamService.teamApplicationList.isEmpty && !teamService.isLoading
                  ? ListView(
                      children: const [
                        Center(
                          child: Text('신청 내역이 없습니다.')
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: teamService.teamApplicationList.length + (teamService.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < teamService.teamApplicationList.length) {
                          final teamApplication = teamService.teamApplicationList[index];

                          return ListTile(
                            title: Text(teamApplication.nickname),
                            subtitle: Text(teamApplication.applicationDate),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _approveApplication(teamApplication),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _rejectApplication(teamApplication),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    ),
            );
          },
        ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_teamService.isLoading && _teamService.hasMoreData) {
        _teamService.getTeamApplicationList(teamId: widget.teamInfo.id, loadMore: true);
      }
    }
  }

  void _approveApplication(TeamApplication teamApplication) {
    try {
      _teamService.processApplication(teamId: widget.teamInfo.id, applicationId: teamApplication.id, action: 'approve');
    } on DioException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message!)),
      );
    }
  }

  void _rejectApplication(TeamApplication teamApplication) {
    try {
      _teamService.processApplication(teamId: widget.teamInfo.id, applicationId: teamApplication.id, action: 'reject');
    } on DioException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message!)),
      );
    }
  }
}
