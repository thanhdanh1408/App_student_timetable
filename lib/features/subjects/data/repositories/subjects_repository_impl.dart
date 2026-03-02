// lib/features/subjects/data/repositories/subjects_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/services/firebase_service.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subjects_repository.dart';

class SubjectsRepositoryImpl implements SubjectsRepository {
  static final SubjectsRepositoryImpl _instance = SubjectsRepositoryImpl._internal();
  factory SubjectsRepositoryImpl() => _instance;
  SubjectsRepositoryImpl._internal();

  final FirebaseService _firebase = FirebaseService();

  /// Get Firestore collection reference for subjects
  CollectionReference<Map<String, dynamic>> get _subjectsCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('subjects');

  @override
  Future<List<SubjectEntity>> getAll() async {
    try {
      if (!_firebase.isAuthenticated || _firebase.currentUserId == null) {
        print('❌ Not authenticated');
        return [];
      }

      final snapshot = await _subjectsCollection.get();

      final subjects = snapshot.docs.map((doc) {
        final data = doc.data();
        data['subject_id'] = doc.id;
        return SubjectEntity.fromJson(data);
      }).toList();

      print('✅ Loaded ${subjects.length} subjects from Firestore');
      return subjects;
    } catch (e) {
      print('❌ Error loading subjects: $e');
      return [];
    }
  }

  @override
  Future<void> add(SubjectEntity subject) async {
    try {
      if (!_firebase.isAuthenticated || _firebase.currentUserId == null) {
        throw Exception('Not authenticated');
      }

      print('📝 [SubjectsRepository] Attempting to add subject: ${subject.subjectName}');
      print('📝 [SubjectsRepository] User authenticated: ${_firebase.currentUserId}');

      final docRef = await _subjectsCollection.add({
        'user_id': _firebase.currentUserId!,
        'subject_name': subject.subjectName,
        'teacher_name': subject.teacherName,
        'color': subject.color,
        'credit': subject.credit,
      });

      print('✅ Subject added to Firestore: ${subject.subjectName}');
      print('✅ Document ID: ${docRef.id}');
    } catch (e) {
      print('❌ Error adding subject: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(SubjectEntity subject) async {
    try {
      if (!_firebase.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      if (subject.id == null) {
        throw Exception('Subject ID cannot be null');
      }

      await _subjectsCollection.doc(subject.id!).update({
        'subject_name': subject.subjectName,
        'teacher_name': subject.teacherName,
        'color': subject.color,
        'credit': subject.credit,
      });

      print('✅ Subject updated in Firestore: ${subject.subjectName}');
    } catch (e) {
      print('❌ Error updating subject: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (!_firebase.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      await _subjectsCollection.doc(id).delete();

      print('✅ Subject deleted from Firestore: ID $id');
    } catch (e) {
      print('❌ Error deleting subject: $e');
      rethrow;
    }
  }
}
