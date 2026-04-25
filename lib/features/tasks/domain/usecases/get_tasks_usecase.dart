import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class GetTasksUsecase {
  final TasksRepository repository;
  GetTasksUsecase(this.repository);

  Future<List<TaskEntity>> call() => repository.getAll();
}
