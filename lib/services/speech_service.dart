import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 음성 서비스 (TTS, STT)
class SpeechService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _isListening = false;

  Future<void> initialize() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  // TTS: 텍스트를 음성으로 변환
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  // STT: 음성을 텍스트로 변환 (사용자 발음 연습용)
  Future<bool> initializeSTT() async {
    return await _stt.initialize();
  }

  Future<void> startListening({
    required Function(String text) onResult,
    Function(String error)? onError,
  }) async {
    if (!_isListening) {
      _isListening = true;
      await _stt.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );
    }
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
  }

  bool get isListening => _isListening;
}
