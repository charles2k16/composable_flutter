import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:4000/api'; // Change this
  static const _storage = FlutterSecureStorage();
  static late Dio _dio;

  static void init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'client_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> checkPhone(String phone) async {
    final res = await _dio.post('/client-auth/check-phone', data: {'phone': phone});
    return res.data;
  }

  static Future<Map<String, dynamic>> setupPin(String phone, String pin) async {
    final res = await _dio.post('/client-auth/setup-pin', data: {'phone': phone, 'pin': pin});
    return res.data;
  }

  static Future<Map<String, dynamic>> loginWithPin(String phone, String pin) async {
    final res = await _dio.post('/client-auth/login', data: {'phone': phone, 'pin': pin});
    return res.data;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/client-auth/me');
    return res.data;
  }

  // ─── Token Management ─────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'client_token', value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: 'client_token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'client_token');
    await _storage.delete(key: 'client_data');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
