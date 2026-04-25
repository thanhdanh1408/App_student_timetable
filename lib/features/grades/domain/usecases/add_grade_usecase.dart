import '../entities/grade_entity.dart';
import '../repositories/grades_repository.dart';

class AddGradeUsecase {
  final GradesRepository repository;
  AddGradeUsecase(this.repository);

  Future<String> call(GradeEntity grade) => repository.add(grade);
}
