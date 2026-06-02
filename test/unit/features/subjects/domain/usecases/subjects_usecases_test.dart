// test/unit/features/subjects/domain/usecases/subjects_usecases_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:student_timetable_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:student_timetable_app/features/subjects/domain/repositories/subjects_repository.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/add_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/delete_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/get_subjects_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/update_subject_usecase.dart';

// Mock class without annotations - using manual extend
class MockSubjectsRepository extends Mock implements SubjectsRepository {
  @override
  Future<List<SubjectEntity>> getAll() => super.noSuchMethod(
        Invocation.method(#getAll, []),
        returnValue: Future<List<SubjectEntity>>.value([]),
      );

  @override
  Future<void> add(SubjectEntity subject) => super.noSuchMethod(
        Invocation.method(#add, [subject]),
        returnValue: Future<void>.value(),
      );

  @override
  Future<void> update(SubjectEntity subject) => super.noSuchMethod(
        Invocation.method(#update, [subject]),
        returnValue: Future<void>.value(),
      );

  @override
  Future<void> delete(String id) => super.noSuchMethod(
        Invocation.method(#delete, [id]),
        returnValue: Future<void>.value(),
      );
}

void main() {
  group('Subjects Usecases', () {
    group('GetSubjectsUsecase', () {
      test('should return list of subjects from repository', () async {
        // Arrange
        final mockRepository = MockSubjectsRepository();
        final getSubjectsUsecase = GetSubjectsUsecase(mockRepository);
        
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
        when(mockRepository.getAll())
            .thenAnswer((_) async => tSubjects);

        // Act
        final result = await getSubjectsUsecase.call();

        // Assert
        expect(result, tSubjects);
        verify(mockRepository.getAll()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when no subjects', () async {
        // Arrange
        final mockRepository = MockSubjectsRepository();
        final getSubjectsUsecase = GetSubjectsUsecase(mockRepository);
        
        when(mockRepository.getAll())
            .thenAnswer((_) async => []);

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
        final mockRepository = MockSubjectsRepository();
        final addSubjectUsecase = AddSubjectUsecase(mockRepository);
        
        final tSubject = SubjectEntity(
          subjectName: 'New Subject',
          teacherName: 'New Teacher',
          credit: 2,
          color: '#FF00FF',
        );
        when(mockRepository.add(tSubject))
            .thenAnswer((_) async {});

        // Act
        await addSubjectUsecase.call(tSubject);

        // Assert
        verify(mockRepository.add(tSubject)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('UpdateSubjectUsecase', () {
      test('should call repository.update with correct subject', () async {
        // Arrange
        final mockRepository = MockSubjectsRepository();
        final updateSubjectUsecase = UpdateSubjectUsecase(mockRepository);
        
        final tSubject = SubjectEntity(
          id: '1',
          subjectName: 'Updated Subject',
          teacherName: 'Updated Teacher',
          credit: 3,
        );
        when(mockRepository.update(tSubject))
            .thenAnswer((_) async {});

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
        final mockRepository = MockSubjectsRepository();
        final deleteSubjectUsecase = DeleteSubjectUsecase(mockRepository);
        
        const tSubjectId = '1';
        when(mockRepository.delete(tSubjectId))
            .thenAnswer((_) async {});

        // Act
        await deleteSubjectUsecase.call(tSubjectId);

        // Assert
        verify(mockRepository.delete(tSubjectId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
