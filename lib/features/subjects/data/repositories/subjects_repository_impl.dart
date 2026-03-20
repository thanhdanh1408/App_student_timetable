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

  /// Get Firestore collection reference for schedules
  CollectionReference<Map<String, dynamic>> get _schedulesCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('schedules');

  /// Get Firestore collection reference for exams
  CollectionReference<Map<String, dynamic>> get _examsCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('exams');

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

      print('🔍 [SubjectsRepository] Deleting subject: $id');
      
      // Step 1: Find and delete all schedules with this subject_id
      final schedulesSnapshot = await _schedulesCollection
          .where('subject_id', isEqualTo: id)
          .get();
      
      print('📋 Found ${schedulesSnapshot.docs.length} schedules to delete');
      
      for (final doc in schedulesSnapshot.docs) {
        await doc.reference.delete();
        print('✅ Deleted schedule: ${doc.id}');
      }

      // Step 2: Find and delete all exams with this subject_id
      final examsSnapshot = await _examsCollection
          .where('subject_id', isEqualTo: id)
          .get();
      
      print('📝 Found ${examsSnapshot.docs.length} exams to delete');
      
      for (final doc in examsSnapshot.docs) {
        await doc.reference.delete();
        print('✅ Deleted exam: ${doc.id}');
      }

      // Step 3: Delete the subject itself
      await _subjectsCollection.doc(id).delete();

      print('✅ Subject deleted from Firestore: ID $id (including ${schedulesSnapshot.docs.length} schedules and ${examsSnapshot.docs.length} exams)');
    } catch (e) {
      print('❌ Error deleting subject: $e');
      rethrow;
    }
  }
}
