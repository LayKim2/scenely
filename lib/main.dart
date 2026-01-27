import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/video_input_screen.dart';
import 'screens/video_detail_screen.dart';
import 'screens/study_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService().initialize();
  
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
        '/': (context) => const HomeScreen(),
        '/video-input': (context) => const VideoInputScreen(),
        '/video-detail': (context) => const VideoDetailScreen(),
        '/study': (context) => const StudyScreen(),
      },
    );
  }
}
