/// 타임코드가 포함된 단어 모델
class TranscriptWord {
  final String text;
  final double startSeconds;
  final double endSeconds;

  TranscriptWord({
    required this.text,
    required this.startSeconds,
    required this.endSeconds,
  });

  factory TranscriptWord.fromJson(Map<String, dynamic> json) {
    return TranscriptWord(
      text: json['text'] as String,
      startSeconds: (json['startSeconds'] as num).toDouble(),
      endSeconds: (json['endSeconds'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
    };
  }
}
