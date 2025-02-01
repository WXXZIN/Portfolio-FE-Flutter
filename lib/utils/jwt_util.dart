import 'dart:convert';

class JwtUtil {
  static Map<String, dynamic> decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded);
  }

  static DateTime getExpirationTime(String token) {
    final decoded = decodeJwt(token);
    final exp = decoded['exp'];
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }
}
