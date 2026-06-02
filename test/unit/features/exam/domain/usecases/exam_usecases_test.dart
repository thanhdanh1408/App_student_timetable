// test/unit/features/exam/domain/usecases/exam_usecases_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:student_timetable_app/features/exam/domain/entities/exam_entity.dart';
import 'package:student_timetable_app/features/exam/domain/repositories/exam_repository.dart';
import 'package:student_timetable_app/features/exam/domain/usecases/add_exam_usecase.dart';
import 'package:student_timetable_app/features/exam/domain/usecases/delete_exam_usecase.dart';
import 'package:student_timetable_app/features/exam/domain/usecases/get_exams_usecase.dart';
import 'package:student_timetable_app/features/exam/domain/usecases/update_exam_usecase.dart';

// Mock class with proper return type handling
class MockExamRepository extends Mock implements ExamRepository {
  @override
  Future<List<ExamEntity>> getAll() => super.noSuchMethod(
        Invocation.method(#getAll, []),
        returnValue: Future<List<ExamEntity>>.value([]),
      );

  @override
    Future<String> add(ExamEntity exam) => super.noSuchMethod(
        Invocation.method(#add, [exam]),
      returnValue: Future<String>.value(''),
      );

  @override
  Future<void> update(ExamEntity exam) => super.noSuchMethod(
        Invocation.method(#update, [exam]),
        returnValue: Future<void>.value(),
      );

  @override
  Future<void> delete(String id) => super.noSuchMethod(
        Invocation.method(#delete, [id]),
        returnValue: Future<void>.value(),
      );
}

void main() {
  group('Exam Usecases', () {
    group('GetExamsUsecase', () {
      test('should return list of exams from repository', () async {
        // Arrange
        final mockRepository = MockExamRepository();
        final getExamsUsecase = GetExamsUsecase(mockRepository);
        
        final tExams = [
          ExamEntity(
            id: '1',
            subjectId: 'subj1',
            subjectName: 'Dart Programming',
            teacherName: 'John Doe',
            examName: 'Cuối kỳ',
            examDate: DateTime(2026, 4, 15),
            examTime: '08:00',
            examRoom: 'Room A101',
          ),
          ExamEntity(
            id: '2',
            subjectId: 'subj2',
            subjectName: 'Flutter Development',
            teacherName: 'Jane Smith',
            examName: 'Giữa kỳ',
            examDate: DateTime(2026, 3, 25),
            examTime: '09:00',
            examRoom: 'Room A202',
          ),
        ];
        when(mockRepository.getAll())
            .thenAnswer((_) async => tExams);

        // Act
        final result = await getExamsUsecase.call();

        // Assert
        expect(result, tExams);
        verify(mockRepository.getAll()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when no exams', () async {
        // Arrange
        final mockRepository = MockExamRepository();
        final getExamsUsecase = GetExamsUsecase(mockRepository);
        
        when(mockRepository.getAll())
            .thenAnswer((_) async => []);

        // Act
        final result = await getExamsUsecase.call();

        // Assert
        expect(result, []);
        verify(mockRepository.getAll()).called(1);
      });
    });

    group('AddExamUsecase', () {
      test('should call repository.add with correct exam', () async {
        // Arrange
        final mockRepository = MockExamRepository();
        final addExamUsecase = AddExamUsecase(mockRepository);
        
        final tExam = ExamEntity(
          subjectId: 'subj1',
          subjectName: 'New Subject',
          teacherName: 'New Teacher',
          examName: 'Cuối kỳ',
          examDate: DateTime(2026, 4, 15),
          examTime: '08:00',
          examRoom: 'Room A101',
        );
        when(mockRepository.add(tExam))
          .thenAnswer((_) async => 'exam-id');

        // Act
        await addExamUsecase.call(tExam);

        // Assert
        verify(mockRepository.add(tExam)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('UpdateExamUsecase', () {
      test('should call repository.update with correct exam', () async {
        // Arrange
        final mockRepository = MockExamRepository();
        final updateExamUsecase = UpdateExamUsecase(mockRepository);
        
        final tExam = ExamEntity(
          id: '1',
          subjectId: 'subj1',
          subjectName: 'Updated Subject',
          examName: 'Cuối kỳ',
          examDate: DateTime(2026, 4, 20),
          examTime: '09:00',
          examRoom: 'Room B101',
        );
        when(mockRepository.update(tExam))
            .thenAnswer((_) async {});

        // Act
        await updateExamUsecase.call(tExam);

        // Assert
        verify(mockRepository.update(tExam)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('DeleteExamUsecase', () {
      test('should call repository.delete with correct id', () async {
        // Arrange
        final mockRepository = MockExamRepository();
        final deleteExamUsecase = DeleteExamUsecase(mockRepository);
        
        const tExamId = '1';
        when(mockRepository.delete(tExamId))
            .thenAnswer((_) async {});

        // Act
        await deleteExamUsecase.call(tExamId);

        // Assert
        verify(mockRepository.delete(tExamId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
