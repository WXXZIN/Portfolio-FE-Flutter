class Project {
  final int id;
  final int teamId;
  final String createdAt;
  final String title;
  final String content;
  final String writerName;
  int viewCount;
  final int requireMemberCount;
  final int currentMemberCount;
  final String deadline;
  final String recruitmentStatus;
  final List<String>? tags;
  int heartCount;
  bool isHearted;
  bool isApplied;
  bool isTeamMember;

  Project({
    required this.id,
    required this.teamId,
    required this.createdAt,
    required this.title,
    required this.content,
    required this.writerName,
    required this.viewCount,
    required this.requireMemberCount,
    required this.currentMemberCount,
    required this.deadline,
    required this.recruitmentStatus,
    required this.tags,
    required this.heartCount,
    required this.isHearted,
    required this.isApplied,
    required this.isTeamMember,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? 0,
      teamId: json['teamId'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      writerName: json['writerName'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      requireMemberCount: json['requireMemberCount'] ?? 0,
      currentMemberCount: json['currentMemberCount'] ?? 0,
      deadline: json['deadline'] ?? '',
      recruitmentStatus: json['recruitmentStatus'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      heartCount: json['heartCount'] ?? 0,
      isHearted: json['isHearted'] ?? false,
      isApplied: json['isApplied'] ?? false,
      isTeamMember: json['isTeamMember'] ?? false,
    );
  }
}
