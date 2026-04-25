import '../entities/grade_entity.dart';

abstract class GradesRepository {
  Future<List<GradeEntity>> getAll();
  Future<String> add(GradeEntity grade);
  Future<void> update(GradeEntity grade);
  Future<void> delete(String id);
}
