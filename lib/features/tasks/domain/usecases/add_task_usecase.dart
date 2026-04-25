import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class AddTaskUsecase {
  final TasksRepository repository;
  AddTaskUsecase(this.repository);

  Future<String> call(TaskEntity task) => repository.add(task);
}
