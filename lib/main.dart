import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'config/kakao_config.dart';
import 'screens/auth_check_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/video_input_screen.dart';
import 'screens/video_detail_screen.dart';
import 'screens/study_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenely',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheckScreen(),
        '/login': (context) => const LoginScreen(),
        '/video-input': (context) => const VideoInputScreen(),
        '/video-detail': (context) => const VideoDetailScreen(),
        '/study': (context) => const StudyScreen(),
      },
    );
  }
}
