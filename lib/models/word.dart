import 'video_segment.dart';

/// 학습 단어 모델
class Word {
  final String id;
  final String text;
  final String? meaning;
  final String? pronunciation;
  final List<String> examples;
  final List<VideoSegment> segments; // 이 단어가 나온 영상 구간들

  Word({
    required this.id,
    required this.text,
    this.meaning,
    this.pronunciation,
    required this.examples,
    required this.segments,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      text: json['text'] as String,
      meaning: json['meaning'] as String?,
      pronunciation: json['pronunciation'] as String?,
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      segments: (json['segments'] as List<dynamic>?)
              ?.map((s) => VideoSegment.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'meaning': meaning,
      'pronunciation': pronunciation,
      'examples': examples,
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }
}
