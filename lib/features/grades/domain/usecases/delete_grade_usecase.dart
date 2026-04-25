import '../repositories/grades_repository.dart';

class DeleteGradeUsecase {
  final GradesRepository repository;
  DeleteGradeUsecase(this.repository);

  Future<void> call(String id) => repository.delete(id);
}
