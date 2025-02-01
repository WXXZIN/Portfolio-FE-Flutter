class Device {
  final int userId;
  final String deviceId;
  final String os;
  final String deviceName;
  final String firstLoginAt;
  final String lastLoginAt;

  Device({
    required this.userId,
    required this.deviceId,
    required this.os,
    required this.deviceName,
    required this.firstLoginAt,
    required this.lastLoginAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      userId: json['userId'],
      deviceId: json['deviceId'],
      os: json['os'],
      deviceName: json['deviceName'],
      firstLoginAt: json['firstLoginAt'],
      lastLoginAt: json['lastLoginAt'],
    );
  }
}
