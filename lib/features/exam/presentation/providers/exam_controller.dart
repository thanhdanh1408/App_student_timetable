// lib/features/exam/presentation/providers/exam_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/usecases/add_exam_usecase.dart';
import '../../domain/usecases/delete_exam_usecase.dart';
import '../../domain/usecases/update_exam_usecase.dart';

/// StateNotifier for managing exam mutations (add/update/delete)
class ExamController extends StateNotifier<AsyncValue<List>> {
  final AddExamUsecase _addUsecase;
  final UpdateExamUsecase _updateUsecase;
  final DeleteExamUsecase _deleteUsecase;

  ExamController({
    required AddExamUsecase addUsecase,
    required UpdateExamUsecase updateUsecase,
    required DeleteExamUsecase deleteUsecase,
  })  : _addUsecase = addUsecase,
        _updateUsecase = updateUsecase,
        _deleteUsecase = deleteUsecase,
        super(const AsyncValue.loading());

  /// Add a new exam
  Future<void> addExam(ExamEntity exam) async {
    state = const AsyncValue.loading();
    try {
      await _addUsecase.call(exam);
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update an existing exam
  Future<void> updateExam(ExamEntity exam) async {
    state = const AsyncValue.loading();
    try {
      await _updateUsecase.call(exam);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete an exam
  Future<void> deleteExam(String examId) async {
    state = const AsyncValue.loading();
    try {
      await _deleteUsecase.call(examId);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
