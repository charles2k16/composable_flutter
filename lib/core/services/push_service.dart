import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (e) {
      debugPrint('Firebase not configured — push disabled: $e');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    _messaging.onTokenRefresh.listen(_registerToken);

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Push received: ${message.notification?.title}');
    });
  }

  static Future<void> registerIfLoggedIn() async {
    if (!_initialized) return;

    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }
  }

  static Future<void> _registerToken(String token) async {
    if (!await ApiClient.isLoggedIn()) return;

    try {
      await ApiClient.registerFcmToken(token);
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }
}
