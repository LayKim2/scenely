import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../config/kakao_config.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

/// 로그인 화면 (카카오 로그인 → POST /auth/kakao → 토큰 저장 → 홈)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  String get _redirectUri =>
      'kakao${kakaoNativeAppKey}://oauth';

  Future<void> _loginWithKakao() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String code;
      final talkInstalled = await isKakaoTalkInstalled();

      if (talkInstalled) {
        code = await AuthCodeClient.instance.authorizeWithTalk(
          redirectUri: _redirectUri,
        );
      } else {
        code = await AuthCodeClient.instance.authorize(
          redirectUri: _redirectUri,
        );
      }

      final apiService = ApiService(baseUrl: apiBaseUrl);
      final response = await apiService.postAuthKakao(code);

      final prefs = await SharedPreferences.getInstance();
      final authStorage = AuthStorage(prefs);
      await authStorage.saveAuth(response);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacementNamed('/');
      }
    } on KakaoAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Scenely',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _loginWithKakao,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black87,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('카카오로 로그인'),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
