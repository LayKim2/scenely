import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_storage.dart';
import 'home_screen.dart';

/// 앱 시작/홈 진입 시 인증 확인 → 로그인 시 홈, 미로그인 시 로그인 화면으로 이동
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  late final Future<bool> _authFuture = () async {
    final prefs = await SharedPreferences.getInstance();
    return AuthStorage(prefs).isLoggedIn;
  }();

  bool _redirectScheduled = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.data!;
        if (!isLoggedIn && !_redirectScheduled) {
          _redirectScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const HomeScreen();
      },
    );
  }
}
