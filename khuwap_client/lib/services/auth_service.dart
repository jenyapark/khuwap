import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  // 로그인 성공 시 저장했던 user_id 불러오기
  static Future<String?> getUserId() async {
    return await _storage.read(key: "user_id");
  }

  // 로그아웃
  static Future<void> logout() async {
    await _storage.delete(key: "user_id");
  }
}