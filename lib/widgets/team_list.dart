import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/services/team/team_service.dart';
import 'package:client_flutter/widgets/custom_dialog.dart';

class TeamList extends StatefulWidget {
  const TeamList({super.key});

  @override
  State<TeamList> createState() => _TeamListState();
}

class _TeamListState extends State<TeamList> {
  late TeamService _teamService;

  @override
  void initState() {
    super.initState();
    _teamService = context.read<TeamService>();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _teamService.clearTeamList();
        await _teamService.getTeamList();
      },
      child: Consumer<TeamService>(
        builder: (context, teamService, child) {
          if (teamService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (teamService.teamList.isEmpty) {
            return ListView(
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 200.0),
                    child: Text('팀이 없습니다.'),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            itemCount: teamService.teamList.length,
            itemBuilder: (context, index) {
              final team = teamService.teamList[index];

              return Slidable(
                key: Key(team.id.toString()),
                endActionPane: ActionPane(
                  extentRatio: 0.25,
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _handleLeaveTeam(teamService, team.id),
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      label: '나가기',
                    ),
                  ]
                ),
                child: ListTile(
                  title: Text(team.name),
                  onTap: () async {
                    try {
                      await teamService.getTeamInfo(teamId: team.id);

                      context.push(
                        '/team/${team.id}',
                        extra: {'teamInfo': teamService.selectedTeam},
                      );
                    } on DioException catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.message!)),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleLeaveTeam(TeamService teamService, int teamId) async {
    final shouldLeave = await showCustomDialog(
      context,
      '팀을 나가시겠습니까?',
      () => Navigator.of(context).pop(false),
      () => Navigator.of(context).pop(true), 
    );
    
    if (shouldLeave == true) {
      try {
        await teamService.leaveTeam(teamId: teamId);
      } on DioException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message!)),
        );
      }
    }
  }
}
