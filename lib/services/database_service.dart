import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/video.dart';
import '../models/study_content.dart';
import '../models/word.dart';

/// 로컬 데이터베이스 서비스
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'scenely.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Videos 테이블
    await db.execute('''
      CREATE TABLE videos (
        id TEXT PRIMARY KEY,
        title TEXT,
        thumbnailUrl TEXT,
        videoUrl TEXT,
        youtubeUrl TEXT,
        durationSeconds INTEGER,
        transcript TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // StudyContents 테이블
    await db.execute('''
      CREATE TABLE study_contents (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        videoId TEXT,
        words TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }

  // Video CRUD
  Future<void> insertVideo(Video video) async {
    final db = await database;
    await db.insert(
      'videos',
      video.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Video?> getVideo(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'videos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Video.fromJson(maps.first);
  }

  Future<List<Video>> getAllVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('videos');
    return maps.map((map) => Video.fromJson(map)).toList();
  }

  Future<void> updateVideo(Video video) async {
    final db = await database;
    await db.update(
      'videos',
      video.toJson(),
      where: 'id = ?',
      whereArgs: [video.id],
    );
  }

  Future<void> deleteVideo(String id) async {
    final db = await database;
    await db.delete(
      'videos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // StudyContent CRUD
  Future<void> insertStudyContent(StudyContent content) async {
    final db = await database;
    await db.insert(
      'study_contents',
      {
        'id': content.id,
        'date': content.date.toIso8601String(),
        'videoId': content.videoId,
        'words': jsonEncode(content.words.map((w) => w.toJson()).toList()),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StudyContent?> getStudyContent(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_contents',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    final map = maps.first;
    final wordsJson = jsonDecode(map['words'] as String) as List<dynamic>;
    return StudyContent(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      videoId: map['videoId'] as String?,
      words: wordsJson.map((w) => Word.fromJson(w as Map<String, dynamic>)).toList(),
    );
  }

  Future<StudyContent?> getTodayStudyContent() async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final List<Map<String, dynamic>> maps = await db.query(
      'study_contents',
      where: 'date LIKE ?',
      whereArgs: ['$todayStr%'],
    );

    if (maps.isEmpty) return null;
    return StudyContent.fromJson(maps.first);
  }

  Future<List<StudyContent>> getAllStudyContents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('study_contents');
    return maps.map((map) {
      final wordsJson = jsonDecode(map['words'] as String) as List<dynamic>;
      return StudyContent(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        videoId: map['videoId'] as String?,
        words: wordsJson.map((w) => Word.fromJson(w as Map<String, dynamic>)).toList(),
      );
    }).toList();
  }

  Future<void> deleteStudyContent(String id) async {
    final db = await database;
    await db.delete(
      'study_contents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
