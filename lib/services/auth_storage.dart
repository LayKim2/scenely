import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// 인증 정보(accessToken, user) 저장/조회
class AuthStorage {
  static const _keyAccessToken = 'accessToken';
  static const _keyUser = 'user';

  final SharedPreferences _prefs;

  AuthStorage(this._prefs);

  Future<void> saveAuth(AuthResponse response) async {
    await _prefs.setString(_keyAccessToken, response.accessToken);
    await _prefs.setString(
      _keyUser,
      jsonEncode({
        'id': response.user.id,
        'email': response.user.email,
        'nickname': response.user.nickname,
        'profileImage': response.user.profileImage,
      }),
    );
  }

  String? get accessToken => _prefs.getString(_keyAccessToken);

  AuthUser? get user {
    final raw = _prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyUser);
  }

  bool get isLoggedIn => accessToken != null;
}
