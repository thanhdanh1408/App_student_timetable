// test/unit/presentation/viewmodels/subjects_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:student_timetable_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/get_subjects_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/add_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/update_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/delete_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/presentation/viewmodels/subjects_viewmodel.dart';

@GenerateMocks([
  GetSubjectsUsecase,
  AddSubjectUsecase,
  UpdateSubjectUsecase,
  DeleteSubjectUsecase,
])
import 'subjects_viewmodel_test.mocks.dart';

void main() {
  late SubjectsViewModel viewModel;
  late MockGetSubjectsUsecase mockGetUsecase;
  late MockAddSubjectUsecase mockAddUsecase;
  late MockUpdateSubjectUsecase mockUpdateUsecase;
  late MockDeleteSubjectUsecase mockDeleteUsecase;

  setUp(() {
    mockGetUsecase = MockGetSubjectsUsecase();
    mockAddUsecase = MockAddSubjectUsecase();
    mockUpdateUsecase = MockUpdateSubjectUsecase();
    mockDeleteUsecase = MockDeleteSubjectUsecase();

    viewModel = SubjectsViewModel(
      get: mockGetUsecase,
      add: mockAddUsecase,
      update: mockUpdateUsecase,
      delete: mockDeleteUsecase,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('SubjectsViewModel - load', () {
    test('should load subjects successfully', () async {
      // Arrange
      final subjects = [
        SubjectEntity(id: '1', subjectName: 'Môn 1'),
        SubjectEntity(id: '2', subjectName: 'Môn 2'),
      ];
      when(mockGetUsecase.call()).thenAnswer((_) async => subjects);

      // Act
      await viewModel.load();

      // Assert
      expect(viewModel.subjects, subjects);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
      verify(mockGetUsecase.call()).called(1);
    });

    test('should set loading state during load', () async {
      // Arrange
      when(mockGetUsecase.call()).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 100),
          () => [],
        ),
      );

      // Act
      final future = viewModel.load();
      
      // Assert - Kiểm tra loading state ngay lập tức
      expect(viewModel.isLoading, true);
      
      await future;
      expect(viewModel.isLoading, false);
    });

    test('should handle error when loading fails', () async {
      // Arrange
      when(mockGetUsecase.call()).thenThrow(Exception('Load failed'));

      // Act
      await viewModel.load();

      // Assert
      expect(viewModel.subjects, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Load failed'));
    });
  });

  group('SubjectsViewModel - add', () {
    test('should add subject and reload list', () async {
      // Arrange
      final newSubject = SubjectEntity(subjectName: 'Môn mới');
      final updatedList = [
        SubjectEntity(id: '1', subjectName: 'Môn mới'),
      ];
      when(mockAddUsecase.call(newSubject)).thenAnswer((_) async => {});
      when(mockGetUsecase.call()).thenAnswer((_) async => updatedList);

      // Act
      await viewModel.add(newSubject);

      // Assert
      expect(viewModel.subjects, updatedList);
      expect(viewModel.error, isNull);
      verify(mockAddUsecase.call(newSubject)).called(1);
      verify(mockGetUsecase.call()).called(1);
    });

    test('should handle error when adding subject fails', () async {
      // Arrange
      final newSubject = SubjectEntity(subjectName: 'Môn mới');
      when(mockAddUsecase.call(newSubject)).thenThrow(Exception('Add failed'));

      // Act
      await viewModel.add(newSubject);

      // Assert
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Add failed'));
    });
  });

  group('SubjectsViewModel - update', () {
    test('should update subject and reload list', () async {
      // Arrange
      final updatedSubject = SubjectEntity(
        id: '1',
        subjectName: 'Môn đã cập nhật',
      );
      final updatedList = [updatedSubject];
      when(mockUpdateUsecase.call(updatedSubject)).thenAnswer((_) async => {});
      when(mockGetUsecase.call()).thenAnswer((_) async => updatedList);

      // Act
      await viewModel.update(updatedSubject);

      // Assert
      expect(viewModel.subjects, updatedList);
      expect(viewModel.error, isNull);
      verify(mockUpdateUsecase.call(updatedSubject)).called(1);
      verify(mockGetUsecase.call()).called(1);
    });

    test('should handle error when updating subject fails', () async {
      // Arrange
      final updatedSubject = SubjectEntity(
        id: '1',
        subjectName: 'Môn đã cập nhật',
      );
      when(mockUpdateUsecase.call(updatedSubject))
          .thenThrow(Exception('Update failed'));

      // Act
      await viewModel.update(updatedSubject);

      // Assert
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Update failed'));
    });
  });

  group('SubjectsViewModel - delete', () {
    test('should delete subject and reload list', () async {
      // Arrange
      const subjectId = '1';
      when(mockDeleteUsecase.call(subjectId)).thenAnswer((_) async => {});
      when(mockGetUsecase.call()).thenAnswer((_) async => []);

      // Act
      await viewModel.delete(subjectId);

      // Assert
      expect(viewModel.subjects, isEmpty);
      expect(viewModel.error, isNull);
      verify(mockDeleteUsecase.call(subjectId)).called(1);
      verify(mockGetUsecase.call()).called(1);
    });

    test('should handle error when deleting subject fails', () async {
      // Arrange
      const subjectId = '1';
      when(mockDeleteUsecase.call(subjectId))
          .thenThrow(Exception('Delete failed'));

      // Act
      await viewModel.delete(subjectId);

      // Assert
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Delete failed'));
    });
  });

  group('SubjectsViewModel - search', () {
    test('should filter subjects by search query', () async {
      // Arrange
      final allSubjects = [
        SubjectEntity(id: '1', subjectName: 'Lập trình'),
        SubjectEntity(id: '2', subjectName: 'Cơ sở dữ liệu'),
        SubjectEntity(id: '3', subjectName: 'Lập trình web'),
      ];
      when(mockGetUsecase.call()).thenAnswer((_) async => allSubjects);
      await viewModel.load();

      // Act
      viewModel.updateSearchQuery('lập trình');

      // Assert
      expect(viewModel.filteredSubjects.length, 2);
      expect(
        viewModel.filteredSubjects.every(
          (s) => s.subjectName.toLowerCase().contains('lập trình'),
        ),
        true,
      );
    });

    test('should return all subjects when search query is empty', () async {
      // Arrange
      final allSubjects = [
        SubjectEntity(id: '1', subjectName: 'Môn 1'),
        SubjectEntity(id: '2', subjectName: 'Môn 2'),
      ];
      when(mockGetUsecase.call()).thenAnswer((_) async => allSubjects);
      await viewModel.load();

      // Act
      viewModel.updateSearchQuery('');

      // Assert
      expect(viewModel.filteredSubjects, allSubjects);
    });

    test('should return empty list when no matches', () async {
      // Arrange
      final allSubjects = [
        SubjectEntity(id: '1', subjectName: 'Toán'),
        SubjectEntity(id: '2', subjectName: 'Lý'),
      ];
      when(mockGetUsecase.call()).thenAnswer((_) async => allSubjects);
      await viewModel.load();

      // Act
      viewModel.updateSearchQuery('xyz không tồn tại');

      // Assert
      expect(viewModel.filteredSubjects, isEmpty);
    });
  });
}
