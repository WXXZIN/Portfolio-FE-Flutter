import 'package:flutter/material.dart';

import 'package:client_flutter/widgets/create_team_dialog.dart';
import 'package:client_flutter/widgets/team_list.dart';

class TeamTab extends StatelessWidget {
  const TeamTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TeamList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CreateTeamDialog();
            },
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.group_add, color: Colors.white),
      ),
    );
  }
}
