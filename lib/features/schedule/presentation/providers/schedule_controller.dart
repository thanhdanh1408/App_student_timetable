// lib/features/schedule/presentation/providers/schedule_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/usecases/add_schedule_usecase.dart';
import '../../domain/usecases/delete_schedule_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';

/// StateNotifier for managing schedule mutations (add/update/delete)
class ScheduleController extends StateNotifier<AsyncValue<List>> {
  final AddScheduleUsecase _addUsecase;
  final UpdateScheduleUsecase _updateUsecase;
  final DeleteScheduleUsecase _deleteUsecase;

  ScheduleController({
    required AddScheduleUsecase addUsecase,
    required UpdateScheduleUsecase updateUsecase,
    required DeleteScheduleUsecase deleteUsecase,
  })  : _addUsecase = addUsecase,
        _updateUsecase = updateUsecase,
        _deleteUsecase = deleteUsecase,
        super(const AsyncValue.loading());

  /// Add a new schedule
  Future<void> addSchedule(ScheduleEntity schedule) async {
    state = const AsyncValue.loading();
    try {
      await _addUsecase.call(schedule);
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update an existing schedule
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    state = const AsyncValue.loading();
    try {
      await _updateUsecase.call(schedule);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String scheduleId) async {
    state = const AsyncValue.loading();
    try {
      await _deleteUsecase.call(scheduleId);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
