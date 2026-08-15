import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import 'push_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> checkPhone(String phone) async {
    return ApiClient.checkPhone(phone);
  }

  static Future<ClientModel?> setupPin(String phone, String pin) async {
    final res = await ApiClient.setupPin(phone, pin);
    return _saveSession(res);
  }

  static Future<ClientModel?> loginWithPin(String phone, String pin) async {
    final res = await ApiClient.loginWithPin(phone, pin);
    return _saveSession(res);
  }

  static Future<ClientModel?> _saveSession(Map<String, dynamic> res) async {
    if (res['access_token'] != null) {
      await ApiClient.saveToken(res['access_token']);
      await _storage.write(key: 'client_data', value: jsonEncode(res['client']));
      await PushService.registerIfLoggedIn();
      return ClientModel.fromJson(res['client']);
    }
    return null;
  }

  static Future<ClientModel?> getProfile() async {
    try {
      final data = await ApiClient.getMe();
      return ClientModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> logout() async {
    await ApiClient.clearToken();
  }

  static Future<bool> isLoggedIn() async {
    return ApiClient.isLoggedIn();
  }

  static Future<Map<String, dynamic>?> getCachedClient() async {
    final data = await _storage.read(key: 'client_data');
    if (data != null) return jsonDecode(data);
    return null;
  }
}
