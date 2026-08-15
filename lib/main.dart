import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/api/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/push_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/phone_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Init API client
  ApiClient.init();

  // Push notifications (no-op if Firebase is not configured)
  await PushService.init();

  // Check login status
  final loggedIn = await AuthService.isLoggedIn();
  if (loggedIn) {
    await PushService.registerIfLoggedIn();
  }

  runApp(ComposablesApp(loggedIn: loggedIn));
}

class ComposablesApp extends StatelessWidget {
  final bool loggedIn;
  const ComposablesApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '可组合业务咨询 IT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: loggedIn ? const HomeScreen() : const PhoneScreen(),
      routes: {
        '/login': (_) => const PhoneScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
