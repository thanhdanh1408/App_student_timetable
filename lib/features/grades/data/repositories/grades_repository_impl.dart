import 'package:cloud_firestore/cloud_firestore.dart';

import '/core/services/firebase_service.dart';
import '../../domain/entities/grade_entity.dart';
import '../../domain/repositories/grades_repository.dart';

class GradesRepositoryImpl implements GradesRepository {
  static final GradesRepositoryImpl _instance = GradesRepositoryImpl._internal();
  factory GradesRepositoryImpl() => _instance;
  GradesRepositoryImpl._internal();

  final FirebaseService _firebase = FirebaseService();

  CollectionReference<Map<String, dynamic>> get _gradesCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('grades');

  CollectionReference<Map<String, dynamic>> get _subjectsCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('subjects');

  @override
  Future<List<GradeEntity>> getAll() async {
    try {
      if (!_firebase.isAuthenticated || _firebase.currentUserId == null) {
        return [];
      }

      final subjectsSnapshot = await _subjectsCollection.get();
      final subjectsMap = <String, Map<String, dynamic>>{};
      for (final doc in subjectsSnapshot.docs) {
        subjectsMap[doc.id] = doc.data();
      }

      final snapshot = await _gradesCollection.get();
      final grades = snapshot.docs.map((doc) {
        final data = doc.data();
        data['grade_id'] = doc.id;

        final subjectId = data['subject_id'] as String?;
        if (subjectId != null && subjectsMap.containsKey(subjectId)) {
          data['subject_name'] = subjectsMap[subjectId]!['subject_name'];
          data['teacher_name'] = subjectsMap[subjectId]!['teacher_name'];
        }

        return GradeEntity.fromJson(data);
      }).toList();

      grades.sort((a, b) {
        final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      return grades;
    } catch (e) {
      print('❌ Error loading grades: $e');
      return [];
    }
  }

  @override
  Future<String> add(GradeEntity grade) async {
    if (!_firebase.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    final docRef = await _gradesCollection.add({
      'subject_id': grade.subjectId,
      'score_10': grade.score10,
      'credit': grade.credit,
      'note': grade.note,
      'updated_at': DateTime.now().toIso8601String(),
    });

    return docRef.id;
  }

  @override
  Future<void> update(GradeEntity grade) async {
    if (!_firebase.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    if (grade.id == null) {
      throw Exception('Grade ID cannot be null');
    }

    await _gradesCollection.doc(grade.id!).update({
      'subject_id': grade.subjectId,
      'score_10': grade.score10,
      'credit': grade.credit,
      'note': grade.note,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> delete(String id) async {
    if (!_firebase.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    await _gradesCollection.doc(id).delete();
  }
}
