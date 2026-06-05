import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../models/models.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> requestOTP(String phone) async {
    return ApiClient.requestOTP(phone);
  }

  static Future<ClientModel?> verifyOTP(String phone, String code) async {
    final res = await ApiClient.verifyOTP(phone, code);
    if (res['access_token'] != null) {
      await ApiClient.saveToken(res['access_token']);
      await _storage.write(key: 'client_data', value: jsonEncode(res['client']));
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
