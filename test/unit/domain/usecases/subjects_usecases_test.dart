// test/unit/domain/usecases/subjects_usecases_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:student_timetable_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:student_timetable_app/features/subjects/domain/repositories/subjects_repository.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/get_subjects_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/add_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/update_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/delete_subject_usecase.dart';

// Tạo mock class
@GenerateMocks([SubjectsRepository])
import 'subjects_usecases_test.mocks.dart';

void main() {
  late MockSubjectsRepository mockRepository;

  setUp(() {
    mockRepository = MockSubjectsRepository();
  });

  group('GetSubjectsUsecase', () {
    test('should get all subjects from repository', () async {
      // Arrange
      final subjects = [
        SubjectEntity(id: '1', subjectName: 'Môn học 1'),
        SubjectEntity(id: '2', subjectName: 'Môn học 2'),
      ];
      when(mockRepository.getAll()).thenAnswer((_) async => subjects);
      final usecase = GetSubjectsUsecase(mockRepository);

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, subjects);
      verify(mockRepository.getAll()).called(1);
    });

    test('should return empty list when no subjects', () async {
      // Arrange
      when(mockRepository.getAll()).thenAnswer((_) async => []);
      final usecase = GetSubjectsUsecase(mockRepository);

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getAll()).called(1);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      when(mockRepository.getAll()).thenThrow(Exception('Database error'));
      final usecase = GetSubjectsUsecase(mockRepository);

      // Act & Assert
      expect(() => usecase.call(), throwsException);
    });
  });

  group('AddSubjectUsecase', () {
    test('should add subject to repository', () async {
      // Arrange
      final subject = SubjectEntity(subjectName: 'Môn học mới');
      when(mockRepository.add(subject)).thenAnswer((_) async => {});
      final usecase = AddSubjectUsecase(mockRepository);

      // Act
      await usecase.call(subject);

      // Assert
      verify(mockRepository.add(subject)).called(1);
    });

    test('should throw exception when add fails', () async {
      // Arrange
      final subject = SubjectEntity(subjectName: 'Môn học mới');
      when(mockRepository.add(subject)).thenThrow(Exception('Add failed'));
      final usecase = AddSubjectUsecase(mockRepository);

      // Act & Assert
      expect(() => usecase.call(subject), throwsException);
    });
  });

  group('UpdateSubjectUsecase', () {
    test('should update subject in repository', () async {
      // Arrange
      final subject = SubjectEntity(
        id: '1',
        subjectName: 'Môn học đã cập nhật',
      );
      when(mockRepository.update(subject)).thenAnswer((_) async => {});
      final usecase = UpdateSubjectUsecase(mockRepository);

      // Act
      await usecase.call(subject);

      // Assert
      verify(mockRepository.update(subject)).called(1);
    });

    test('should throw exception when update fails', () async {
      // Arrange
      final subject = SubjectEntity(
        id: '1',
        subjectName: 'Môn học đã cập nhật',
      );
      when(mockRepository.update(subject)).thenThrow(Exception('Update failed'));
      final usecase = UpdateSubjectUsecase(mockRepository);

      // Act & Assert
      expect(() => usecase.call(subject), throwsException);
    });
  });

  group('DeleteSubjectUsecase', () {
    test('should delete subject from repository', () async {
      // Arrange
      const subjectId = '123';
      when(mockRepository.delete(subjectId)).thenAnswer((_) async => {});
      final usecase = DeleteSubjectUsecase(mockRepository);

      // Act
      await usecase.call(subjectId);

      // Assert
      verify(mockRepository.delete(subjectId)).called(1);
    });

    test('should throw exception when delete fails', () async {
      // Arrange
      const subjectId = '123';
      when(mockRepository.delete(subjectId))
          .thenThrow(Exception('Delete failed'));
      final usecase = DeleteSubjectUsecase(mockRepository);

      // Act & Assert
      expect(() => usecase.call(subjectId), throwsException);
    });
  });
}
