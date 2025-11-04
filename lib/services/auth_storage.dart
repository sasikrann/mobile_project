import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kRole = 'user_role';
  static const _kUsername = 'user_name';
  static const _kName = 'name';

  static Future<void> saveLogin({
    required String token,
    required int userId,
    required String role,
    required String username,
    required String name,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    await sp.setInt(_kUserId, userId);
    await sp.setString(_kRole, role);
    await sp.setString(_kUsername, username);
    await sp.setString(_kName, name);
  }

  static Future<Map<String, dynamic>> getAll() async {
    final sp = await SharedPreferences.getInstance();
    return {
      'token': sp.getString(_kToken),
      'id': sp.getInt(_kUserId),
      'role': sp.getString(_kRole),
      'username': sp.getString(_kUsername),
      'name': sp.getString(_kName),
    };
  }

  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  static Future<int?> getUserId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kUserId);
  }

  static Future<String?> getRole() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kRole);
  }

  static Future<Map<String, dynamic>> getUser() async {
    final sp = await SharedPreferences.getInstance();
    return {
      'id': sp.getInt(_kUserId),
      'role': sp.getString(_kRole),
      'username': sp.getString(_kUsername),
      'name': sp.getString(_kName),
    };
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final id = await getUserId();
    return token != null && id != null;
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kUserId);
    await sp.remove(_kRole);
    await sp.remove(_kUsername);
    await sp.remove(_kName);
  }
}