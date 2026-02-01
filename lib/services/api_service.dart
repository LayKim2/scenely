import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';
import '../models/study_content.dart';

/// 서버 API 통신 서비스
class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({required this.baseUrl}) : _client = http.Client();

  /// 카카오 인증 코드로 로그인
  Future<AuthResponse> postAuthKakao(String code) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/kakao'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthResponse.fromJson(data);
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  // Job 생성
  Future<String> createJob({
    String? youtubeUrl,
    String? filePath,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/jobs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (youtubeUrl != null) 'youtubeUrl': youtubeUrl,
        if (filePath != null) 'filePath': filePath,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['jobId'] as String;
    } else {
      throw Exception('Failed to create job: ${response.statusCode}');
    }
  }

  // Job 상태 조회
  Future<JobStatus> getJobStatus(String jobId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/jobs/$jobId/status'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return JobStatus.fromJson(data);
    } else {
      throw Exception('Failed to get job status: ${response.statusCode}');
    }
  }

  // Job 결과 조회
  Future<JobResult> getJobResult(String jobId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/jobs/$jobId/result'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return JobResult.fromJson(data);
    } else {
      throw Exception('Failed to get job result: ${response.statusCode}');
    }
  }

  // 파일 업로드
  Future<String> uploadFile(String filePath) async {
    // 실제 구현 시 multipart/form-data로 파일 업로드
    // 여기서는 간단한 예시만 제공
    throw UnimplementedError('File upload not implemented yet');
  }
}

/// Job 상태 모델
class JobStatus {
  final String jobId;
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final String? currentStep; // 'upload', 'ffmpeg', 'asr', 'gemini'
  final double? progress; // 0.0 ~ 1.0
  final String? error;

  JobStatus({
    required this.jobId,
    required this.status,
    this.currentStep,
    this.progress,
    this.error,
  });

  factory JobStatus.fromJson(Map<String, dynamic> json) {
    return JobStatus(
      jobId: json['jobId'] as String,
      status: json['status'] as String,
      currentStep: json['currentStep'] as String?,
      progress: json['progress'] != null
          ? (json['progress'] as num).toDouble()
          : null,
      error: json['error'] as String?,
    );
  }
}

/// Job 결과 모델
class JobResult {
  final String jobId;
  final Video? video;
  final StudyContent? studyContent;

  JobResult({
    required this.jobId,
    this.video,
    this.studyContent,
  });

  factory JobResult.fromJson(Map<String, dynamic> json) {
    return JobResult(
      jobId: json['jobId'] as String,
      video: json['video'] != null
          ? Video.fromJson(json['video'] as Map<String, dynamic>)
          : null,
      studyContent: json['studyContent'] != null
          ? StudyContent.fromJson(
              json['studyContent'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// /auth/kakao 응답
class AuthResponse {
  final String accessToken;
  final AuthUser user;

  AuthResponse({required this.accessToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// 인증된 사용자 정보
class AuthUser {
  final String id;
  final String? email;
  final String? nickname;
  final String? profileImage;

  AuthUser({
    required this.id,
    this.email,
    this.nickname,
    this.profileImage,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }
}
