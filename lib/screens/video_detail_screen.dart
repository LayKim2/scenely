import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';
import '../services/video_service.dart';
import '../widgets/progress_indicator.dart';
import '../models/video.dart';

/// 영상 상세 화면
class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({super.key});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  final ApiService _apiService = ApiService(baseUrl: 'YOUR_SERVER_URL');
  final VideoService _videoService = VideoService();
  String? _jobId;
  Video? _video;
  JobStatus? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _jobId = args?['jobId'] as String?;

    if (_jobId != null) {
      await _pollStatus();
    }
  }

  Future<void> _pollStatus() async {
    while (mounted) {
      try {
        final status = await _apiService.getJobStatus(_jobId!);
        setState(() {
          _status = status;
        });

        if (status.status == 'completed') {
          final result = await _apiService.getJobResult(_jobId!);
          setState(() {
            _video = result.video;
            _isLoading = false;
          });
          if (_video?.videoUrl != null) {
            await _videoService.initializeVideo(_video!.videoUrl!);
          }
          break;
        } else if (status.status == 'failed') {
          setState(() {
            _isLoading = false;
          });
          break;
        }

        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    _videoService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_video?.title ?? '영상 분석'),
      ),
      body: _isLoading
          ? Center(
              child: _jobId != null
                  ? ProgressIndicatorWidget(
                      jobId: _jobId!,
                      apiService: _apiService,
                    )
                  : const CircularProgressIndicator(),
            )
          : _video == null
              ? const Center(child: Text('영상을 불러올 수 없습니다'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_videoService.controller != null &&
                          _videoService.controller!.value.isInitialized)
                        AspectRatio(
                          aspectRatio: _videoService.controller!.value.aspectRatio,
                          child: VideoPlayer(_videoService.controller!),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_video!.title != null)
                              Text(
                                _video!.title!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_videoService.controller != null) {
                                  if (_videoService.controller!.value.isPlaying) {
                                    _videoService.pause();
                                  } else {
                                    _videoService.play();
                                  }
                                  setState(() {});
                                }
                              },
                              child: Icon(
                                _videoService.controller?.value.isPlaying == true
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
