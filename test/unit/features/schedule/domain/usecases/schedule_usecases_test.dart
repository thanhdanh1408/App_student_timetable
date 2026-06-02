// test/unit/features/schedule/domain/usecases/schedule_usecases_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:student_timetable_app/features/schedule/domain/entities/schedule_entity.dart';
import 'package:student_timetable_app/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:student_timetable_app/features/schedule/domain/usecases/add_schedule_usecase.dart';
import 'package:student_timetable_app/features/schedule/domain/usecases/delete_schedule_usecase.dart';
import 'package:student_timetable_app/features/schedule/domain/usecases/get_schedules_usecase.dart';
import 'package:student_timetable_app/features/schedule/domain/usecases/update_schedule_usecase.dart';

// Mock class with proper return type handling
class MockScheduleRepository extends Mock implements ScheduleRepository {
  @override
  Future<List<ScheduleEntity>> getAll() => super.noSuchMethod(
        Invocation.method(#getAll, []),
        returnValue: Future<List<ScheduleEntity>>.value([]),
      );

  @override
    Future<String> add(ScheduleEntity schedule) => super.noSuchMethod(
        Invocation.method(#add, [schedule]),
      returnValue: Future<String>.value(''),
      );

  @override
  Future<void> update(ScheduleEntity schedule) => super.noSuchMethod(
        Invocation.method(#update, [schedule]),
        returnValue: Future<void>.value(),
      );

  @override
  Future<void> delete(String id) => super.noSuchMethod(
        Invocation.method(#delete, [id]),
        returnValue: Future<void>.value(),
      );
}

void main() {
  group('Schedule Usecases', () {
    group('GetSchedulesUsecase', () {
      test('should return list of schedules from repository', () async {
        // Arrange
        final mockRepository = MockScheduleRepository();
        final getSchedulesUsecase = GetSchedulesUsecase(mockRepository);
        
        final tSchedules = [
          ScheduleEntity(
            id: '1',
            subjectId: 'subj1',
            subjectName: 'Dart Programming',
            teacherName: 'John Doe',
            dayOfWeek: 2,
            startTime: '07:30',
            endTime: '09:00',
            location: 'Room A101',
          ),
          ScheduleEntity(
            id: '2',
            subjectId: 'subj2',
            subjectName: 'Flutter Development',
            teacherName: 'Jane Smith',
            dayOfWeek: 3,
            startTime: '09:15',
            endTime: '11:00',
            location: 'Room A202',
          ),
        ];
        when(mockRepository.getAll())
            .thenAnswer((_) async => tSchedules);

        // Act
        final result = await getSchedulesUsecase.call();

        // Assert
        expect(result, tSchedules);
        verify(mockRepository.getAll()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when no schedules', () async {
        // Arrange
        final mockRepository = MockScheduleRepository();
        final getSchedulesUsecase = GetSchedulesUsecase(mockRepository);
        
        when(mockRepository.getAll())
            .thenAnswer((_) async => []);

        // Act
        final result = await getSchedulesUsecase.call();

        // Assert
        expect(result, []);
        verify(mockRepository.getAll()).called(1);
      });
    });

    group('AddScheduleUsecase', () {
      test('should call repository.add with correct schedule', () async {
        // Arrange
        final mockRepository = MockScheduleRepository();
        final addScheduleUsecase = AddScheduleUsecase(mockRepository);
        
        final tSchedule = ScheduleEntity(
          subjectId: 'subj1',
          subjectName: 'New Subject',
          teacherName: 'New Teacher',
          dayOfWeek: 2,
          startTime: '07:30',
          endTime: '09:00',
          location: 'Room A101',
        );
        when(mockRepository.add(tSchedule))
          .thenAnswer((_) async => 'schedule-id');

        // Act
        await addScheduleUsecase.call(tSchedule);

        // Assert
        verify(mockRepository.add(tSchedule)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('UpdateScheduleUsecase', () {
      test('should call repository.update with correct schedule', () async {
        // Arrange
        final mockRepository = MockScheduleRepository();
        final updateScheduleUsecase = UpdateScheduleUsecase(mockRepository);
        
        final tSchedule = ScheduleEntity(
          id: '1',
          subjectId: 'subj1',
          subjectName: 'Updated Subject',
          dayOfWeek: 3,
          startTime: '09:15',
          endTime: '11:00',
          location: 'Room B101',
        );
        when(mockRepository.update(tSchedule))
            .thenAnswer((_) async {});

        // Act
        await updateScheduleUsecase.call(tSchedule);

        // Assert
        verify(mockRepository.update(tSchedule)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('DeleteScheduleUsecase', () {
      test('should call repository.delete with correct id', () async {
        // Arrange
        final mockRepository = MockScheduleRepository();
        final deleteScheduleUsecase = DeleteScheduleUsecase(mockRepository);
        
        const tScheduleId = '1';
        when(mockRepository.delete(tScheduleId))
            .thenAnswer((_) async {});

        // Act
        await deleteScheduleUsecase.call(tScheduleId);

        // Assert
        verify(mockRepository.delete(tScheduleId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
