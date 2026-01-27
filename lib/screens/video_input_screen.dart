import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/youtube_permission_checkbox.dart';
import '../services/api_service.dart';

/// 영상 입력 화면
class VideoInputScreen extends StatefulWidget {
  const VideoInputScreen({super.key});

  @override
  State<VideoInputScreen> createState() => _VideoInputScreenState();
}

class _VideoInputScreenState extends State<VideoInputScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ApiService _apiService = ApiService(baseUrl: 'YOUR_SERVER_URL');
  bool _youtubePermissionChecked = false;
  bool _isUploading = false;
  String? _selectedFilePath;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _urlController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (_urlController.text.isEmpty && _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL 또는 파일을 입력해주세요')),
      );
      return;
    }

    if (_urlController.text.isNotEmpty && !_youtubePermissionChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('YouTube 권한 확인에 동의해주세요')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String jobId;
      if (_urlController.text.isNotEmpty) {
        jobId = await _apiService.createJob(youtubeUrl: _urlController.text);
      } else {
        // 파일 업로드 구현 필요
        throw UnimplementedError('File upload not implemented');
      }

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/video-detail',
          arguments: {'jobId': jobId},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영상 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'YouTube URL 또는 파일을 업로드하세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://www.youtube.com/watch?v=...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _youtubePermissionChecked = false;
                });
              },
            ),
            if (_urlController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              YoutubePermissionCheckbox(
                onChanged: (value) {
                  setState(() {
                    _youtubePermissionChecked = value;
                  });
                },
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              '또는',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('파일 선택'),
            ),
            if (_selectedFilePath != null) ...[
              const SizedBox(height: 8),
              Text(
                '선택된 파일: ${_selectedFilePath!.split('/').last}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _isUploading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('분석 시작'),
            ),
          ],
        ),
      ),
    );
  }
}
