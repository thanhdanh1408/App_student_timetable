import '../repositories/tasks_repository.dart';

class DeleteTaskUsecase {
  final TasksRepository repository;
  DeleteTaskUsecase(this.repository);

  Future<void> call(String id) => repository.delete(id);
}
