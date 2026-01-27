import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video.dart';
import '../models/study_content.dart';

/// Firebase 서비스
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _firestore;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
  }

  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  // Video CRUD
  Future<void> saveVideo(Video video) async {
    await firestore.collection('videos').doc(video.id).set(video.toJson());
  }

  Future<Video?> getVideo(String id) async {
    final doc = await firestore.collection('videos').doc(id).get();
    if (!doc.exists) return null;
    return Video.fromJson(doc.data()!);
  }

  Stream<List<Video>> watchVideos() {
    return firestore.collection('videos').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Video.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> updateVideo(Video video) async {
    await firestore.collection('videos').doc(video.id).update(video.toJson());
  }

  Future<void> deleteVideo(String id) async {
    await firestore.collection('videos').doc(id).delete();
  }

  // StudyContent CRUD
  Future<void> saveStudyContent(StudyContent content) async {
    await firestore
        .collection('study_contents')
        .doc(content.id)
        .set(content.toJson());
  }

  Future<StudyContent?> getStudyContent(String id) async {
    final doc = await firestore.collection('study_contents').doc(id).get();
    if (!doc.exists) return null;
    return StudyContent.fromJson(doc.data()!);
  }

  Future<StudyContent?> getTodayStudyContent() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await firestore
        .collection('study_contents')
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return StudyContent.fromJson(querySnapshot.docs.first.data());
  }

  Stream<List<StudyContent>> watchStudyContents() {
    return firestore.collection('study_contents').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyContent.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> deleteStudyContent(String id) async {
    await firestore.collection('study_contents').doc(id).delete();
  }
}
