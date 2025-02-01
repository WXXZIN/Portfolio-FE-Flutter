class Team {
  final int id;
  final String name;
  final String leaderName;
  List<String> memberNames;
  int memberCount;
  final String projectName;
  String projectStatus;
  bool isTeamLeader;

  Team({
    required this.id,
    required this.name,
    required this.leaderName,
    required this.memberNames,
    required this.memberCount,
    required this.projectName,
    required this.projectStatus,
    required this.isTeamLeader
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      leaderName: json['leaderName'],
      memberNames: List<String>.from(json['memberNames'] ?? []),
      memberCount: json['memberCount'],
      projectName: json['projectName'] ?? '미정',
      projectStatus: json['projectStatus'] ?? '프로젝트 미정',
      isTeamLeader: json['isTeamLeader']
    );
  }
}
