// lib/features/subjects/presentation/providers/subjects_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/subjects_repository_impl.dart';
import '../../domain/usecases/add_subject_usecase.dart';
import '../../domain/usecases/delete_subject_usecase.dart';
import '../../domain/usecases/get_subjects_usecase.dart';
import '../../domain/usecases/update_subject_usecase.dart';
import 'subjects_controller.dart';

/// Repository provider for subjects
final subjectsRepositoryProvider = Provider<SubjectsRepositoryImpl>((ref) {
  return SubjectsRepositoryImpl();
});

/// Use case providers
final getSubjectsUsecaseProvider = Provider<GetSubjectsUsecase>((ref) {
  return GetSubjectsUsecase(ref.watch(subjectsRepositoryProvider));
});

final addSubjectUsecaseProvider = Provider<AddSubjectUsecase>((ref) {
  return AddSubjectUsecase(ref.watch(subjectsRepositoryProvider));
});

final updateSubjectUsecaseProvider = Provider<UpdateSubjectUsecase>((ref) {
  return UpdateSubjectUsecase(ref.watch(subjectsRepositoryProvider));
});

final deleteSubjectUsecaseProvider = Provider<DeleteSubjectUsecase>((ref) {
  return DeleteSubjectUsecase(ref.watch(subjectsRepositoryProvider));
});

/// Subjects list stream provider (reactive)
final subjectsListProvider = FutureProvider((ref) async {
  final usecase = ref.watch(getSubjectsUsecaseProvider);
  return usecase.call();
});

/// Subjects controller provider (for state mutations)
final subjectsControllerProvider = StateNotifierProvider<
    SubjectsController,
    AsyncValue<List>>(
  (ref) {
    final addUsecase = ref.watch(addSubjectUsecaseProvider);
    final updateUsecase = ref.watch(updateSubjectUsecaseProvider);
    final deleteUsecase = ref.watch(deleteSubjectUsecaseProvider);
    return SubjectsController(
      addUsecase: addUsecase,
      updateUsecase: updateUsecase,
      deleteUsecase: deleteUsecase,
      ref: ref,
    );
  },
);
