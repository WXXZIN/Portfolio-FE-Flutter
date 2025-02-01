import 'package:client_flutter/models/project.dart';
import 'package:client_flutter/widgets/project_list.dart';
import 'package:flutter/material.dart';

class ProjectActivityScreen extends StatelessWidget {
  final String title;
  final List<Project> projectList;

  const ProjectActivityScreen({
    super.key, 
    required this.title,
    required this.projectList
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey('project_activity_screen'),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold)
          ),
        ),
      body: ProjectList(projectList: projectList)
    );
  }
}
