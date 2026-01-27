import 'package:flutter/material.dart';
import '../models/study_content.dart';
import '../models/word.dart';
import '../services/video_service.dart';
import '../services/speech_service.dart';

/// 학습 화면
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final VideoService _videoService = VideoService();
  final SpeechService _speechService = SpeechService();
  StudyContent? _studyContent;
  int _currentWordIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _speechService.initialize();
    // 실제로는 데이터베이스나 API에서 오늘의 학습 콘텐츠를 가져와야 함
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _videoService.dispose();
    super.dispose();
  }

  Word? get _currentWord {
    if (_studyContent == null || _studyContent!.words.isEmpty) return null;
    if (_currentWordIndex >= _studyContent!.words.length) return null;
    return _studyContent!.words[_currentWordIndex];
  }

  Future<void> _playWordSegment() async {
    final word = _currentWord;
    if (word != null && word.segments.isNotEmpty) {
      await _videoService.playSegment(word.segments.first);
    }
  }

  Future<void> _speakWord() async {
    final word = _currentWord;
    if (word != null) {
      await _speechService.speak(word.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_studyContent == null || _studyContent!.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('오늘의 학습')),
        body: const Center(
          child: Text('오늘의 학습 콘텐츠가 없습니다'),
        ),
      );
    }

    final word = _currentWord!;
    final progress = (_currentWordIndex + 1) / _studyContent!.words.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 학습'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      word.text,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (word.pronunciation != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        word.pronunciation!,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    if (word.meaning != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        word.meaning!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                    if (word.examples.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        '예문:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...word.examples.map((example) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              example,
                              style: const TextStyle(fontSize: 16),
                            ),
                          )),
                    ],
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 32),
                          onPressed: _speakWord,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.play_circle, size: 32),
                          onPressed: _playWordSegment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentWordIndex > 0
                      ? () {
                          setState(() {
                            _currentWordIndex--;
                          });
                        }
                      : null,
                  child: const Text('이전'),
                ),
                Text(
                  '${_currentWordIndex + 1} / ${_studyContent!.words.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: _currentWordIndex < _studyContent!.words.length - 1
                      ? () {
                          setState(() {
                            _currentWordIndex++;
                          });
                        }
                      : null,
                  child: const Text('다음'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
