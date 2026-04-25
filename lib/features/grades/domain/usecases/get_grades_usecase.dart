import '../entities/grade_entity.dart';
import '../repositories/grades_repository.dart';

class GetGradesUsecase {
  final GradesRepository repository;
  GetGradesUsecase(this.repository);

  Future<List<GradeEntity>> call() => repository.getAll();
}
