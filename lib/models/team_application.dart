class TeamApplication {
  final int id;
  final String nickname;
  final String applicationStatus;
  final String applicationDate;

  TeamApplication({
    required this.id,
    required this.nickname,
    required this.applicationStatus,
    required this.applicationDate,
  });

  factory TeamApplication.fromJson(Map<String, dynamic> json) {
    return TeamApplication(
      id: json['id'],
      nickname: json['nickname'],
      applicationStatus: json['applicationStatus'],
      applicationDate: json['applicationDate'],
    );
  }
}