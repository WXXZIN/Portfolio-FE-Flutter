import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/models/team.dart';
import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/screens/project/write_project_screen.dart';
import 'package:client_flutter/services/project/project_service.dart';
import 'package:client_flutter/services/team/team_service.dart';
import 'package:client_flutter/widgets/project_list.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final teamService = context.watch<TeamService>();
    final projectService = context.watch<ProjectService>();
    final projectList = projectService.projectList;

    return Scaffold(
      body: ProjectList(projectList: projectList),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          if (authProvider.isAuthenticated == false) {
            context.push('/auth/social/login');
          } else {
            final teamList = teamService.teamList;
            _showProjectWriteScreen(context, projectService, teamList);
          }
        },
        heroTag: 'home_fab',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.create, color: Colors.white),
      ),
    );
  }

  void _showProjectWriteScreen(
    BuildContext context, 
    ProjectService projectService, 
    List<Team> teamList
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      barrierColor: Colors.white,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return WriteProjectScreen(teamList: teamList);
      },
    ).then((result) {
      if (result == true) {
        projectService.clearProjectList();
        projectService.getProjectList();
      }
    });
  }
}
