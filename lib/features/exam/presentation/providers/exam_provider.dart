// lib/features/exam/presentation/providers/exam_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/exam_repository_impl.dart';
import '../../domain/usecases/add_exam_usecase.dart';
import '../../domain/usecases/delete_exam_usecase.dart';
import '../../domain/usecases/get_exams_usecase.dart';
import '../../domain/usecases/update_exam_usecase.dart';
import 'exam_controller.dart';

/// Repository provider for exams
final examRepositoryProvider = Provider<ExamRepositoryImpl>((ref) {
  return ExamRepositoryImpl();
});

/// Use case providers
final getExamsUsecaseProvider = Provider<GetExamsUsecase>((ref) {
  return GetExamsUsecase(ref.watch(examRepositoryProvider));
});

final addExamUsecaseProvider = Provider<AddExamUsecase>((ref) {
  return AddExamUsecase(ref.watch(examRepositoryProvider));
});

final updateExamUsecaseProvider = Provider<UpdateExamUsecase>((ref) {
  return UpdateExamUsecase(ref.watch(examRepositoryProvider));
});

final deleteExamUsecaseProvider = Provider<DeleteExamUsecase>((ref) {
  return DeleteExamUsecase(ref.watch(examRepositoryProvider));
});

/// Exams list stream provider (reactive)
final examsListProvider = FutureProvider.autoDispose((ref) async {
  final usecase = ref.watch(getExamsUsecaseProvider);
  return usecase.call();
});

/// Exams controller provider (for state mutations)
final examControllerProvider = StateNotifierProvider.autoDispose<
    ExamController,
    AsyncValue<List>>(
  (ref) {
    final addUsecase = ref.watch(addExamUsecaseProvider);
    final updateUsecase = ref.watch(updateExamUsecaseProvider);
    final deleteUsecase = ref.watch(deleteExamUsecaseProvider);
    return ExamController(
      addUsecase: addUsecase,
      updateUsecase: updateUsecase,
      deleteUsecase: deleteUsecase,
    );
  },
);
