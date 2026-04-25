import 'package:flutter/material.dart';

import '../../domain/entities/grade_entity.dart';
import '../../domain/usecases/add_grade_usecase.dart';
import '../../domain/usecases/delete_grade_usecase.dart';
import '../../domain/usecases/get_grades_usecase.dart';
import '../../domain/usecases/update_grade_usecase.dart';

class GradesViewModel with ChangeNotifier {
  final GetGradesUsecase _get;
  final AddGradeUsecase _add;
  final UpdateGradeUsecase _update;
  final DeleteGradeUsecase _delete;

  GradesViewModel({
    required GetGradesUsecase get,
    required AddGradeUsecase add,
    required UpdateGradeUsecase update,
    required DeleteGradeUsecase delete,
  })  : _get = get,
        _add = add,
        _update = update,
        _delete = delete;

  List<GradeEntity> _grades = [];
  bool _isLoading = false;
  String? _error;

  List<GradeEntity> get grades => _grades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get gpa4 {
    if (_grades.isEmpty) return 0;
    final totalCredits = _grades.fold<int>(0, (sum, g) => sum + g.credit);
    if (totalCredits == 0) return 0;

    final weighted = _grades.fold<double>(
      0,
      (sum, g) => sum + (g.score4 * g.credit),
    );

    return weighted / totalCredits;
  }

  double get gpa10 {
    if (_grades.isEmpty) return 0;
    final totalCredits = _grades.fold<int>(0, (sum, g) => sum + g.credit);
    if (totalCredits == 0) return 0;

    final weighted = _grades.fold<double>(
      0,
      (sum, g) => sum + (g.score10 * g.credit),
    );

    return weighted / totalCredits;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _grades = await _get();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(GradeEntity grade) async {
    try {
      await _add(grade);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> update(GradeEntity grade) async {
    try {
      await _update(grade);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete(id);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
