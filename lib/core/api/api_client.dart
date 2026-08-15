import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';

class ApiClient {
  static const String _productionBaseUrl =
      'https://installmngbackend-production.up.railway.app/api';

  /// Override at build time:
  /// `flutter run --dart-define=API_BASE=https://installmngbackend-production.up.railway.app/api`
  /// `flutter run --dart-define=API_HOST=localhost` (local backend on port 4000)
  static String get baseUrl {
    const apiBase = String.fromEnvironment('API_BASE');
    if (apiBase.isNotEmpty) return apiBase;

    const apiHost = String.fromEnvironment('API_HOST');
    if (apiHost.isNotEmpty) {
      if (apiHost.startsWith('http')) {
        return apiHost.endsWith('/api') ? apiHost : '$apiHost/api';
      }
      return 'http://$apiHost:4000/api';
    }

    return _productionBaseUrl;
  }

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

  static Future<void> registerFcmToken(String token) async {
    await _dio.post('/client-auth/register-fcm-token', data: {'token': token});
  }

  static Future<List<ClientNotification>> getNotifications() async {
    final res = await _dio.get('/client-auth/notifications');
    final list = res.data as List;
    return list.map((item) => ClientNotification.fromJson(item)).toList();
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
