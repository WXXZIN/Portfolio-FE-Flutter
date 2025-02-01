class User {
  final String provider;
  final String nickname;
  final String email;

  User({
    required this.provider,
    required this.nickname,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      provider: json['provider'],
      nickname: json['nickname'],
      email: json['email'],
    );
  }
}
