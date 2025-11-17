import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class Config {
  // ✅ ตั้งไว้จุดเดียว เปลี่ยนที่เดียวทั้งแอป
  static const apiBase = 'http://192.168.20.240:3000';
}

class ApiClient {
  static Uri _u(String path) => Uri.parse('${Config.apiBase}$path');

  static Future<http.Response> get(String path) async {
    final headers = await AuthStorage.authHeaders();
    final res = await http.get(_u(path), headers: headers);
    _throwIfUnauthorized(res);
    return res;
  }

  static Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final headers = await AuthStorage.authHeaders();
    final res = await http.post(_u(path), headers: headers, body: jsonEncode(body ?? {}));
    _throwIfUnauthorized(res);
    return res;
  }

  static void _throwIfUnauthorized(http.Response res) {
    if (res.statusCode == 401) {
      // ตรงนี้จะโยนให้ caller ไปเคลียร์ session/redirect ต่อ
      throw const ApiUnauthorized();
    }
  }
}

class ApiUnauthorized implements Exception {
  const ApiUnauthorized();
  @override
  String toString() => 'ApiUnauthorized/ password error.';
}