// lib/features/schedule/data/repositories/schedule_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/services/firebase_service.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  static final ScheduleRepositoryImpl _instance = ScheduleRepositoryImpl._internal();
  factory ScheduleRepositoryImpl() => _instance;
  ScheduleRepositoryImpl._internal();

  final FirebaseService _firebase = FirebaseService();

  /// Get Firestore collection reference for schedules
  CollectionReference<Map<String, dynamic>> get _schedulesCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('schedules');

  /// Get Firestore collection reference for subjects
  CollectionReference<Map<String, dynamic>> get _subjectsCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('subjects');

  @override
  Future<List<ScheduleEntity>> getAll() async {
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

      // Then get all schedules
      final snapshot = await _schedulesCollection.get();

      print('📋 Raw response from schedules query: ${snapshot.docs.length} docs');

      final schedules = snapshot.docs.map((doc) {
        final data = doc.data();
        data['schedule_id'] = doc.id;

        // Denormalize subject info
        final subjectId = data['subject_id'] as String?;
        if (subjectId != null && subjectsMap.containsKey(subjectId)) {
          final subjectData = subjectsMap[subjectId]!;
          data['subject_name'] = subjectData['subject_name'];
          data['teacher_name'] = subjectData['teacher_name'];
        }

        print('📋 Schedule: ${doc.id}, Subject: ${data['subject_name']}');
        final schedule = ScheduleEntity.fromJson(data);
        print(
          '✅ Denormalized schedule - subjectName: ${schedule.subjectName}, teacherName: ${schedule.teacherName}',
        );
        return schedule;
      }).toList();

      print('✅ Loaded ${schedules.length} schedules from Firestore');
      return schedules;
    } catch (e) {
      print('❌ Error loading schedules: $e');
      return [];
    }
  }

  @override
  Future<String> add(ScheduleEntity schedule) async {
    try {
      if (!_firebase.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final userId = _firebase.currentUserId;
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final docRef = await _schedulesCollection.add({
        'subject_id': schedule.subjectId,
        'day_of_week': schedule.dayOfWeek,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'location': schedule.location,
        'color': schedule.color,
        'is_enabled': schedule.isEnabled,
      });

      final scheduleId = docRef.id;
      print('✅ Schedule added to Firestore: ${schedule.subjectName}, ID: $scheduleId');
      return scheduleId;
    } catch (e) {
      print('❌ Error adding schedule: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(ScheduleEntity schedule) async {
    try {
      if (!_firebase.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      if (schedule.id == null) {
        throw Exception('Schedule ID cannot be null');
      }

      await _schedulesCollection.doc(schedule.id!).update({
        'subject_id': schedule.subjectId,
        'day_of_week': schedule.dayOfWeek,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'location': schedule.location,
        'color': schedule.color,
        'is_enabled': schedule.isEnabled,
      });

      print('✅ Schedule updated in Firestore: ${schedule.subjectName}');
    } catch (e) {
      print('❌ Error updating schedule: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (!_firebase.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      await _schedulesCollection.doc(id).delete();

      print('✅ Schedule deleted from Firestore: ID $id');
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      rethrow;
    }
  }
}
