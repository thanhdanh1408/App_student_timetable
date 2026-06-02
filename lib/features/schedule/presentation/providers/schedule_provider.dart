// lib/features/schedule/presentation/providers/schedule_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/usecases/add_schedule_usecase.dart';
import '../../domain/usecases/delete_schedule_usecase.dart';
import '../../domain/usecases/get_schedules_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';
import 'schedule_controller.dart';

/// Repository provider for schedules
final scheduleRepositoryProvider = Provider<ScheduleRepositoryImpl>((ref) {
  return ScheduleRepositoryImpl();
});

/// Use case providers
final getSchedulesUsecaseProvider = Provider<GetSchedulesUsecase>((ref) {
  return GetSchedulesUsecase(ref.watch(scheduleRepositoryProvider));
});

final addScheduleUsecaseProvider = Provider<AddScheduleUsecase>((ref) {
  return AddScheduleUsecase(ref.watch(scheduleRepositoryProvider));
});

final updateScheduleUsecaseProvider = Provider<UpdateScheduleUsecase>((ref) {
  return UpdateScheduleUsecase(ref.watch(scheduleRepositoryProvider));
});

final deleteScheduleUsecaseProvider = Provider<DeleteScheduleUsecase>((ref) {
  return DeleteScheduleUsecase(ref.watch(scheduleRepositoryProvider));
});

/// Schedules list stream provider (reactive)
final schedulesListProvider = FutureProvider((ref) async {
  final usecase = ref.watch(getSchedulesUsecaseProvider);
  return usecase.call();
});

/// Schedules controller provider (for state mutations)
final scheduleControllerProvider = StateNotifierProvider<
    ScheduleController,
    AsyncValue<List>>(
  (ref) {
    final addUsecase = ref.watch(addScheduleUsecaseProvider);
    final updateUsecase = ref.watch(updateScheduleUsecaseProvider);
    final deleteUsecase = ref.watch(deleteScheduleUsecaseProvider);
    return ScheduleController(
      addUsecase: addUsecase,
      updateUsecase: updateUsecase,
      deleteUsecase: deleteUsecase,
      ref: ref,
    );
  },
);
