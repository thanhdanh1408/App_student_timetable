// lib/features/exam/data/repositories/exam_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/services/firebase_service.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/repositories/exam_repository.dart';

class ExamRepositoryImpl implements ExamRepository {
  static final ExamRepositoryImpl _instance = ExamRepositoryImpl._internal();
  factory ExamRepositoryImpl() => _instance;
  ExamRepositoryImpl._internal();

  final FirebaseService _firebase = FirebaseService();

  /// Get Firestore collection reference for exams
  CollectionReference<Map<String, dynamic>> get _examsCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('exams');

  /// Get Firestore collection reference for subjects
  CollectionReference<Map<String, dynamic>> get _subjectsCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('subjects');

  @override
  Future<List<ExamEntity>> getAll() async {
    try {
      if (!_firebase.isAuthenticated) {
        print('❌ Not authenticated');
        return [];
      }

      final userId = _firebase.currentUserId;
      if (userId == null) {
        print('❌ User ID is null');
        return [];
      }

      // First, get all subjects for this user (for denormalization)
      final subjectsSnapshot = await _subjectsCollection.get();
      final subjectsMap = <String, Map<String, dynamic>>{};
      for (final doc in subjectsSnapshot.docs) {
        subjectsMap[doc.id] = doc.data();
      }

      // Then get all exams
      final snapshot = await _examsCollection.get();

      print('📋 Raw response from exams query: ${snapshot.docs.length} docs');

      final exams = snapshot.docs.map((doc) {
        final data = doc.data();
        data['exam_id'] = doc.id;

        // Denormalize subject info
        final subjectId = data['subject_id'] as String?;
        if (subjectId != null && subjectsMap.containsKey(subjectId)) {
          final subjectData = subjectsMap[subjectId]!;
          data['subject_name'] = subjectData['subject_name'];
          data['teacher_name'] = subjectData['teacher_name'];
        }

        print('📋 Exam: ${doc.id}, Subject: ${data['subject_name']}');
        final exam = ExamEntity.fromJson(data);
        print(
          '✅ Denormalized exam - subjectName: ${exam.subjectName}, teacherName: ${exam.teacherName}',
        );
        return exam;
      }).toList();

      // Sort by exam date
      exams.sort((a, b) {
        if (a.examDate == null || b.examDate == null) return 0;
        return a.examDate!.compareTo(b.examDate!);
      });

      print('✅ Loaded ${exams.length} exams from Firestore');
      return exams;
    } catch (e) {
      print('❌ Error loading exams: $e');
      return [];
    }
  }

  @override
  Future<String> add(ExamEntity exam) async {
    try {
      if (!_firebase.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final userId = _firebase.currentUserId;
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final docRef = await _examsCollection.add({
        'subject_id': exam.subjectId,
        'exam_date': exam.examDate != null ? exam.examDate!.toIso8601String() : null,
        'exam_time': exam.examTime,
        'exam_name': exam.examName,
        'exam_room': exam.examRoom,
        'color': exam.color,
        'is_completed': exam.isCompleted,
      });

      final examId = docRef.id;
      print('✅ Exam added to Firestore: ${exam.examName} (ID: $examId)');
      return examId;
    } catch (e) {
      print('❌ Error adding exam: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(ExamEntity exam) async {
    try {
      if (!_firebase.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      if (exam.id == null) {
        throw Exception('Exam ID cannot be null');
      }

      await _examsCollection.doc(exam.id!).update({
        'subject_id': exam.subjectId,
        'exam_date': exam.examDate != null ? exam.examDate!.toIso8601String() : null,
        'exam_time': exam.examTime,
        'exam_name': exam.examName,
        'exam_room': exam.examRoom,
        'color': exam.color,
        'is_completed': exam.isCompleted,
      });

      print('✅ Exam updated in Firestore: ${exam.examName}');
    } catch (e) {
      print('❌ Error updating exam: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (!_firebase.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      await _examsCollection.doc(id).delete();

      print('✅ Exam deleted from Firestore: ID $id');
    } catch (e) {
      print('❌ Error deleting exam: $e');
      rethrow;
    }
  }
}
