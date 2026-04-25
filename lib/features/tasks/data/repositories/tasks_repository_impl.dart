import 'package:cloud_firestore/cloud_firestore.dart';

import '/core/services/firebase_service.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  static final TasksRepositoryImpl _instance = TasksRepositoryImpl._internal();
  factory TasksRepositoryImpl() => _instance;
  TasksRepositoryImpl._internal();

  final FirebaseService _firebase = FirebaseService();

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firebase.firestore.collection('users').doc(_firebase.currentUserId).collection('tasks');

  @override
  Future<List<TaskEntity>> getAll() async {
    try {
      if (!_firebase.isAuthenticated || _firebase.currentUserId == null) {
        return [];
      }

      final snapshot = await _tasksCollection.get();
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        data['task_id'] = doc.id;
        return TaskEntity.fromJson(data);
      }).toList();

      tasks.sort((a, b) {
        final aDue = a.dueDate ?? DateTime(2999);
        final bDue = b.dueDate ?? DateTime(2999);
        return aDue.compareTo(bDue);
      });

      return tasks;
    } catch (e) {
      print('❌ Error loading tasks: $e');
      return [];
    }
  }

  @override
  Future<String> add(TaskEntity task) async {
    if (!_firebase.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    final docRef = await _tasksCollection.add({
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'status': task.status,
      'due_date': task.dueDate?.toIso8601String(),
      'is_completed': task.isCompleted,
      'notes': task.notes,
      'created_at': DateTime.now().toIso8601String(),
    });

    return docRef.id;
  }

  @override
  Future<void> update(TaskEntity task) async {
    if (!_firebase.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    if (task.id == null) {
      throw Exception('Task ID cannot be null');
    }

    await _tasksCollection.doc(task.id!).update({
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'status': task.status,
      'due_date': task.dueDate?.toIso8601String(),
      'is_completed': task.isCompleted,
      'notes': task.notes,
    });
  }

  @override
  Future<void> delete(String id) async {
    if (!_firebase.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    await _tasksCollection.doc(id).delete();
  }
}
