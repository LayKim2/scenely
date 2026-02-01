import 'dart:io';
import 'package:video_player/video_player.dart';
import '../models/video.dart';
import '../models/video_segment.dart';

/// 영상 재생 서비스
class VideoService {
  VideoPlayerController? _controller;

  VideoPlayerController? get controller => _controller;

  Future<void> initializeVideo(String videoUrl) async {
    await dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    await _controller!.initialize();
  }

  Future<void> initializeLocalVideo(String filePath) async {
    await dispose();
    _controller = VideoPlayerController.file(File(filePath));
    await _controller!.initialize();
  }

  Future<void> seekTo(double seconds) async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.seekTo(Duration(milliseconds: (seconds * 1000).toInt()));
    }
  }

  Future<void> playSegment(VideoSegment segment) async {
    await seekTo(segment.startSeconds);
    if (_controller != null) {
      await _controller!.play();
      
      // 구간 종료 시 자동 정지
      _controller!.addListener(() {
        if (_controller!.value.position.inSeconds >= segment.endSeconds.toInt()) {
          _controller!.pause();
        }
      });
    }
  }

  Future<void> play() async {
    await _controller?.play();
  }

  Future<void> pause() async {
    await _controller?.pause();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
