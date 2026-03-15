import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/init.dart' as ic;
import '../controllers/auth_controller.dart';
import '../controllers/session_controller.dart';
import '../screens/login_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ic.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Alyp-Kettik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

/// Decides the initial screen based on auth and session state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      if (!auth.isLoggedIn) {
        return const LoginScreen();
      }

      // Logged in — check for active session
      final session = Get.find<SessionController>();
      session.fetchActiveSession();

      return Obx(() {
        if (session.hasActiveSession) {
          return const HomePage();
        }
        return const QrScannerScreen();
      });
    });
  }
}
