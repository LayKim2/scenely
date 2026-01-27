import 'transcript_word.dart';

/// 영상 구간 모델
class VideoSegment {
  final double startSeconds;
  final double endSeconds;
  final List<TranscriptWord> words;
  final String? description;

  VideoSegment({
    required this.startSeconds,
    required this.endSeconds,
    required this.words,
    this.description,
  });

  factory VideoSegment.fromJson(Map<String, dynamic> json) {
    return VideoSegment(
      startSeconds: (json['startSeconds'] as num).toDouble(),
      endSeconds: (json['endSeconds'] as num).toDouble(),
      words: (json['words'] as List<dynamic>)
          .map((w) => TranscriptWord.fromJson(w as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
      'words': words.map((w) => w.toJson()).toList(),
      'description': description,
    };
  }
}
