import 'package:flutter/material.dart';

import '/core/services/notification_service.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

class TasksViewModel with ChangeNotifier {
  final GetTasksUsecase _get;
  final AddTaskUsecase _add;
  final UpdateTaskUsecase _update;
  final DeleteTaskUsecase _delete;

  TasksViewModel({
    required GetTasksUsecase get,
    required AddTaskUsecase add,
    required UpdateTaskUsecase update,
    required DeleteTaskUsecase delete,
  })  : _get = get,
        _add = add,
        _update = update,
        _delete = delete;

  List<TaskEntity> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskEntity> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TaskEntity> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<TaskEntity> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _get();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(TaskEntity task) async {
    try {
      final id = await _add(task);
      final added = task.copyWith(id: id);
      await _scheduleReminder(added);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> update(TaskEntity task) async {
    try {
      await _update(task);
      if (task.id != null) {
        await NotificationService().cancelNotification(task.id!);
      }
      await _scheduleReminder(task);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleCompleted(TaskEntity task, bool value) async {
    final status = value ? 'Done' : 'Todo';
    await update(task.copyWith(isCompleted: value, status: status));
  }

  Future<void> delete(String id) async {
    try {
      await _delete(id);
      await NotificationService().cancelNotification(id);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _scheduleReminder(TaskEntity task) async {
    if (task.id == null || task.dueDate == null || task.isCompleted) {
      return;
    }

    final reminderTime = task.dueDate!.subtract(const Duration(minutes: 30));
    final now = DateTime.now();

    if (reminderTime.isBefore(now.add(const Duration(seconds: 30)))) {
      return;
    }

    await NotificationService().scheduleNotification(
      id: task.id!,
      title: '⏰ Sắp tới deadline',
      body: '${task.title}${task.notes != null && task.notes!.isNotEmpty ? '\nGhi chú: ${task.notes}' : ''}',
      scheduledTime: reminderTime,
      payload: 'task_${task.id}',
      type: 'general',
    );
  }
}
