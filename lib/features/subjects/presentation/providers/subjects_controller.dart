// lib/features/subjects/presentation/providers/subjects_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/usecases/add_subject_usecase.dart';
import '../../domain/usecases/delete_subject_usecase.dart';
import '../../domain/usecases/update_subject_usecase.dart';
import 'subjects_provider.dart';

/// StateNotifier for managing subject mutations (add/update/delete)
class SubjectsController extends StateNotifier<AsyncValue<List>> {
  final AddSubjectUsecase _addUsecase;
  final UpdateSubjectUsecase _updateUsecase;
  final DeleteSubjectUsecase _deleteUsecase;
  final Ref _ref;

  SubjectsController({
    required AddSubjectUsecase addUsecase,
    required UpdateSubjectUsecase updateUsecase,
    required DeleteSubjectUsecase deleteUsecase,
    required Ref ref,
  })  : _addUsecase = addUsecase,
        _updateUsecase = updateUsecase,
        _deleteUsecase = deleteUsecase,
        _ref = ref,
        super(const AsyncValue.loading());

  /// Add a new subject
  Future<void> addSubject(SubjectEntity subject) async {
    state = const AsyncValue.loading();
    try {
      await _addUsecase.call(subject);
      // Invalidate the subjects list provider to trigger refresh
      _ref.invalidate(subjectsListProvider);
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update an existing subject
  Future<void> updateSubject(SubjectEntity subject) async {
    state = const AsyncValue.loading();
    try {
      await _updateUsecase.call(subject);
      // Invalidate the subjects list provider to trigger refresh
      _ref.invalidate(subjectsListProvider);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a subject
  Future<void> deleteSubject(String subjectId) async {
    state = const AsyncValue.loading();
    try {
      await _deleteUsecase.call(subjectId);
      // Invalidate the subjects list provider to trigger refresh
      _ref.invalidate(subjectsListProvider);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
