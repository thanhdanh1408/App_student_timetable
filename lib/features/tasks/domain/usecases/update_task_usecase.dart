import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class UpdateTaskUsecase {
  final TasksRepository repository;
  UpdateTaskUsecase(this.repository);

  Future<void> call(TaskEntity task) => repository.update(task);
}
