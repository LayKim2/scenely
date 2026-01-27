import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// 진행 상태 표시 위젯
class ProgressIndicatorWidget extends StatefulWidget {
  final String jobId;
  final ApiService apiService;

  const ProgressIndicatorWidget({
    super.key,
    required this.jobId,
    required this.apiService,
  });

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget> {
  JobStatus? _status;
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    _pollStatus();
  }

  Future<void> _pollStatus() async {
    while (_isPolling && mounted) {
      try {
        final status = await widget.apiService.getJobStatus(widget.jobId);
        setState(() {
          _status = status;
        });

        if (status.status == 'completed' || status.status == 'failed') {
          _isPolling = false;
          break;
        }

        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        if (mounted) {
          setState(() {
            _isPolling = false;
          });
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  String _getStepName(String? step) {
    switch (step) {
      case 'upload':
        return '업로드 중...';
      case 'ffmpeg':
        return '오디오 추출 중...';
      case 'asr':
        return '음성 인식 중...';
      case 'gemini':
        return '분석 중...';
      default:
        return '처리 중...';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: _status!.progress ?? 0.0,
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        Text(
          _getStepName(_status!.currentStep),
          style: const TextStyle(fontSize: 14),
        ),
        if (_status!.error != null) ...[
          const SizedBox(height: 8),
          Text(
            '오류: ${_status!.error}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
