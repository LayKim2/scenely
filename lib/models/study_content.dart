import 'word.dart';

/// 하루 학습 콘텐츠 모델
class StudyContent {
  final String id;
  final DateTime date;
  final List<Word> words;
  final String? videoId;

  StudyContent({
    required this.id,
    required this.date,
    required this.words,
    this.videoId,
  });

  factory StudyContent.fromJson(Map<String, dynamic> json) {
    return StudyContent(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      words: (json['words'] as List<dynamic>)
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList(),
      videoId: json['videoId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'words': words.map((w) => w.toJson()).toList(),
      'videoId': videoId,
    };
  }
}
