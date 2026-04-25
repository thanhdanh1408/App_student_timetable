import '../entities/grade_entity.dart';
import '../repositories/grades_repository.dart';

class UpdateGradeUsecase {
  final GradesRepository repository;
  UpdateGradeUsecase(this.repository);

  Future<void> call(GradeEntity grade) => repository.update(grade);
}
