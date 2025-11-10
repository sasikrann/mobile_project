// upload_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_storage.dart';

/// Service for creating/updating rooms with multipart image upload.
class UploadService {
  /// Create a new room
  static Future<Map<String, dynamic>> createRoom({
    required String name,
    String? description,
    int? capacity,
    File? imageFile,
  }) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${Config.apiBase}/api/rooms');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name;
    if (description != null) req.fields['description'] = description;
    if (capacity != null) req.fields['capacity'] = capacity.toString();
    if (imageFile != null && await imageFile.exists()) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final res = await req.send();
    final body = await http.Response.fromStream(res);
    final decoded = _tryDecode(body.body);
    return {'statusCode': body.statusCode, 'body': decoded};
  }

  /// Update existing room
  static Future<Map<String, dynamic>> updateRoom({
    required int roomId,
    String? name,
    String? description,
    int? capacity,
    String? status,
    File? imageFile,
  }) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${Config.apiBase}/api/rooms/$roomId');
    final req = http.MultipartRequest('PUT', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token';
    if (name != null) req.fields['name'] = name;
    if (description != null) req.fields['description'] = description;
    if (capacity != null) req.fields['capacity'] = capacity.toString();
    if (status != null) req.fields['status'] = status;
    if (imageFile != null && await imageFile.exists()) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final res = await req.send();
    final body = await http.Response.fromStream(res);
    final decoded = _tryDecode(body.body);
    return {'statusCode': body.statusCode, 'body': decoded};
  }

  static dynamic _tryDecode(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return s;
    }
  }
}
