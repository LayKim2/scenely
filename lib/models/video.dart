import 'transcript_word.dart';

import 'transcript_word.dart';

/// 영상 모델
class Video {
  final String id;
  final String? title;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? youtubeUrl;
  final int? durationSeconds;
  final List<TranscriptWord>? transcript;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Video({
    required this.id,
    this.title,
    this.thumbnailUrl,
    this.videoUrl,
    this.youtubeUrl,
    this.durationSeconds,
    this.transcript,
    this.createdAt,
    this.updatedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      transcript: (json['transcript'] as List<dynamic>?)
          ?.map((t) => TranscriptWord.fromJson(t as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'youtubeUrl': youtubeUrl,
      'durationSeconds': durationSeconds,
      'transcript': transcript?.map((t) => t.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
