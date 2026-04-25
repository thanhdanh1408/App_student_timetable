import '../entities/task_entity.dart';

abstract class TasksRepository {
  Future<List<TaskEntity>> getAll();
  Future<String> add(TaskEntity task);
  Future<void> update(TaskEntity task);
  Future<void> delete(String id);
}
