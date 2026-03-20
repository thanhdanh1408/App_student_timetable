// test/unit/features/subjects/domain/usecases/subjects_usecases_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:student_timetable_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:student_timetable_app/features/subjects/domain/repositories/subjects_repository.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/add_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/delete_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/get_subjects_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/update_subject_usecase.dart';

// Generate mocks
class MockSubjectsRepository extends Mock implements SubjectsRepository {}

void main() {
  group('Subjects Usecases', () {
    late MockSubjectsRepository mockRepository;
    late GetSubjectsUsecase getSubjectsUsecase;
    late AddSubjectUsecase addSubjectUsecase;
    late UpdateSubjectUsecase updateSubjectUsecase;
    late DeleteSubjectUsecase deleteSubjectUsecase;

    setUp(() {
      mockRepository = MockSubjectsRepository();
      getSubjectsUsecase = GetSubjectsUsecase(mockRepository);
      addSubjectUsecase = AddSubjectUsecase(mockRepository);
      updateSubjectUsecase = UpdateSubjectUsecase(mockRepository);
      deleteSubjectUsecase = DeleteSubjectUsecase(mockRepository);
    });

    group('GetSubjectsUsecase', () {
      test('should return list of subjects from repository', () async {
        // Arrange
        final tSubjects = [
          SubjectEntity(
            id: '1',
            subjectName: 'Dart Programming',
            teacherName: 'John Doe',
            credit: 3,
            color: '#FF0000',
          ),
          SubjectEntity(
            id: '2',
            subjectName: 'Flutter Development',
            teacherName: 'Jane Smith',
            credit: 4,
            color: '#00FF00',
          ),
        ];
        when(mockRepository.getAll()).thenAnswer((_) async => tSubjects);

        // Act
        final result = await getSubjectsUsecase.call();

        // Assert
        expect(result, tSubjects);
        verify(mockRepository.getAll()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when no subjects', () async {
        // Arrange
        when(mockRepository.getAll()).thenAnswer((_) async => []);

        // Act
        final result = await getSubjectsUsecase.call();

        // Assert
        expect(result, []);
        verify(mockRepository.getAll()).called(1);
      });
    });

    group('AddSubjectUsecase', () {
      test('should call repository.add with correct subject', () async {
        // Arrange
        final tSubject = SubjectEntity(
          subjectName: 'New Subject',
          teacherName: 'New Teacher',
          credit: 2,
          color: '#FF00FF',
        );
        when(mockRepository.add(tSubject)).thenAnswer((_) async => {});

        // Act
        await addSubjectUsecase.call(tSubject);

        // Assert
        verify(mockRepository.add(tSubject)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should throw when repository throws', () async {
        // Arrange
        final tSubject = SubjectEntity(
          subjectName: 'Subject',
          teacherName: 'Teacher',
        );
        when(mockRepository.add(tSubject)).thenThrow(Exception('Add failed'));

        // Act & Assert
        expect(
          () => addSubjectUsecase.call(tSubject),
          throwsException,
        );
      });
    });

    group('UpdateSubjectUsecase', () {
      test('should call repository.update with correct subject', () async {
        // Arrange
        final tSubject = SubjectEntity(
          id: '1',
          subjectName: 'Updated Subject',
          teacherName: 'Updated Teacher',
          credit: 3,
        );
        when(mockRepository.update(tSubject)).thenAnswer((_) async => {});

        // Act
        await updateSubjectUsecase.call(tSubject);

        // Assert
        verify(mockRepository.update(tSubject)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('DeleteSubjectUsecase', () {
      test('should call repository.delete with correct id', () async {
        // Arrange
        const tSubjectId = '1';
        when(mockRepository.delete(tSubjectId)).thenAnswer((_) async => {});

        // Act
        await deleteSubjectUsecase.call(tSubjectId);

        // Assert
        verify(mockRepository.delete(tSubjectId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
