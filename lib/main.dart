import 'package:app_auth_firebase_ppb/screens/home.dart';
import 'package:app_auth_firebase_ppb/screens/login.dart';
import 'package:app_auth_firebase_ppb/screens/notifications_setting.dart';
import 'package:app_auth_firebase_ppb/screens/register.dart';
import 'package:app_auth_firebase_ppb/sevices/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initializeNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'home': (context) => const HomeScreen(),
        'notification': (context) => const NotificationScreen(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
      },
      navigatorKey: navigatorKey,
    );
  }
}
