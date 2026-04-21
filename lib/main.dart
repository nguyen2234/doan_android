import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart'; // Màn hình chính có bottom navigation
import 'utils/session.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý chi tiêu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final userId = await Session.get();
    if (!mounted) return;
    if (userId == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    final user = await DBHelper.getUserById(userId);
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      // Sau khi tìm được user, chuyển sang màn hình chính
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen(user: user)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
