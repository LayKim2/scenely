import 'package:flutter/material.dart';

/// YouTube 권한 확인 체크박스 위젯
class YoutubePermissionCheckbox extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  final bool initialValue;

  const YoutubePermissionCheckbox({
    super.key,
    required this.onChanged,
    this.initialValue = false,
  });

  @override
  State<YoutubePermissionCheckbox> createState() =>
      _YoutubePermissionCheckboxState();
}

class _YoutubePermissionCheckboxState extends State<YoutubePermissionCheckbox> {
  bool _isChecked = false;
  bool _showTerms = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isChecked,
              onChanged: (value) {
                setState(() {
                  _isChecked = value ?? false;
                });
                widget.onChanged(_isChecked);
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showTerms = !_showTerms;
                  });
                },
                child: const Text(
                  'YouTube 콘텐츠 분석에 대한 권한을 확인했습니다. '
                  '권한이 있는 콘텐츠만 분석합니다.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        if (_showTerms)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 8, bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '처리 정책:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• 원본 영상/오디오는 영구 저장하지 않습니다',
                    style: TextStyle(fontSize: 11),
                  ),
                  Text(
                    '• 오디오는 임시 파일로만 생성 후 즉시 삭제됩니다',
                    style: TextStyle(fontSize: 11),
                  ),
                  Text(
                    '• 분석 결과만 저장됩니다',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
