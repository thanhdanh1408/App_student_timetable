// test/integration/features/subjects_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:student_timetable_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:student_timetable_app/features/subjects/data/repositories/subjects_repository_impl.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/get_subjects_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/add_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/update_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/domain/usecases/delete_subject_usecase.dart';
import 'package:student_timetable_app/features/subjects/presentation/viewmodels/subjects_viewmodel.dart';
import 'package:student_timetable_app/core/services/firebase_service.dart';

@GenerateMocks([SubjectsRepositoryImpl, FirebaseService])
import 'subjects_integration_test.mocks.dart';

void main() {
  late SubjectsViewModel viewModel;
  late MockSubjectsRepositoryImpl mockRepository;
  late GetSubjectsUsecase getUsecase;
  late AddSubjectUsecase addUsecase;
  late UpdateSubjectUsecase updateUsecase;
  late DeleteSubjectUsecase deleteUsecase;

  setUp(() {
    mockRepository = MockSubjectsRepositoryImpl();

    // Khởi tạo use cases với mock repository
    getUsecase = GetSubjectsUsecase(mockRepository);
    addUsecase = AddSubjectUsecase(mockRepository);
    updateUsecase = UpdateSubjectUsecase(mockRepository);
    deleteUsecase = DeleteSubjectUsecase(mockRepository);

    // Khởi tạo ViewModel với các use cases
    viewModel = SubjectsViewModel(
      get: getUsecase,
      add: addUsecase,
      update: updateUsecase,
      delete: deleteUsecase,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('Subjects Integration Tests - Full Flow', () {
    test('Complete user flow: load -> add -> update -> delete', () async {
      // 1. LOAD - Danh sách ban đầu trống
      when(mockRepository.getAll()).thenAnswer((_) async => []);
      await viewModel.load();
      
      expect(viewModel.subjects, isEmpty);
      expect(viewModel.isLoading, false);

      // 2. ADD - Thêm môn học mới
      final newSubject = SubjectEntity(
        subjectName: 'Lập trình di động',
        teacherName: 'Nguyễn Văn A',
        color: '#FF5733',
        credit: 3,
      );

      final addedSubject = newSubject.copyWith(id: 'generated-id-1');
      
      when(mockRepository.add(newSubject)).thenAnswer((_) async => {});
      when(mockRepository.getAll()).thenAnswer((_) async => [addedSubject]);

      await viewModel.add(newSubject);

      expect(viewModel.subjects.length, 1);
      expect(viewModel.subjects.first.id, 'generated-id-1');
      expect(viewModel.subjects.first.subjectName, 'Lập trình di động');

      // 3. UPDATE - Cập nhật môn học
      final updatedSubject = addedSubject.copyWith(
        subjectName: 'Lập trình di động nâng cao',
        credit: 4,
      );

      when(mockRepository.update(updatedSubject)).thenAnswer((_) async => {});
      when(mockRepository.getAll()).thenAnswer((_) async => [updatedSubject]);

      await viewModel.update(updatedSubject);

      expect(viewModel.subjects.length, 1);
      expect(viewModel.subjects.first.subjectName, 'Lập trình di động nâng cao');
      expect(viewModel.subjects.first.credit, 4);

      // 4. DELETE - Xóa môn học
      when(mockRepository.delete('generated-id-1')).thenAnswer((_) async => {});
      when(mockRepository.getAll()).thenAnswer((_) async => []);

      await viewModel.delete('generated-id-1');

      expect(viewModel.subjects, isEmpty);
    });

    test('Multiple subjects management', () async {
      // Setup - Thêm nhiều môn học
      final subjects = [
        SubjectEntity(
          id: '1',
          subjectName: 'Toán cao cấp',
          teacherName: 'Giáo viên A',
          credit: 4,
        ),
        SubjectEntity(
          id: '2',
          subjectName: 'Vật lý đại cương',
          teacherName: 'Giáo viên B',
          credit: 3,
        ),
        SubjectEntity(
          id: '3',
          subjectName: 'Hóa học',
          teacherName: 'Giáo viên C',
          credit: 2,
        ),
      ];

      when(mockRepository.getAll()).thenAnswer((_) async => subjects);
      await viewModel.load();

      expect(viewModel.subjects.length, 3);

      // Test search functionality
      viewModel.updateSearchQuery('toán');
      expect(viewModel.filteredSubjects.length, 1);
      expect(viewModel.filteredSubjects.first.subjectName, 'Toán cao cấp');

      viewModel.updateSearchQuery('vật lý');
      expect(viewModel.filteredSubjects.length, 1);

      viewModel.updateSearchQuery('');
      expect(viewModel.filteredSubjects.length, 3);

      // Delete one subject
      when(mockRepository.delete('2')).thenAnswer((_) async => {});
      when(mockRepository.getAll()).thenAnswer(
        (_) async => subjects.where((s) => s.id != '2').toList(),
      );

      await viewModel.delete('2');
      expect(viewModel.subjects.length, 2);
      expect(viewModel.subjects.any((s) => s.id == '2'), false);
    });

    test('Error handling throughout the flow', () async {
      // Load error
      when(mockRepository.getAll()).thenThrow(Exception('Network error'));
      await viewModel.load();
      
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Network error'));

      // Add error
      final subject = SubjectEntity(subjectName: 'Test');
      when(mockRepository.add(subject)).thenThrow(Exception('Database error'));
      await viewModel.add(subject);
      
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Database error'));
    });

    test('Loading state management', () async {
      // Setup async repository call
      when(mockRepository.getAll()).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return [];
        },
      );

      // Start loading
      final future = viewModel.load();
      
      // Should be loading
      expect(viewModel.isLoading, true);

      // Wait for completion
      await future;

      // Should not be loading
      expect(viewModel.isLoading, false);
    });
  });

  group('Edge Cases', () {
    test('should handle null/empty teacher name', () async {
      final subject = SubjectEntity(
        id: '1',
        subjectName: 'Môn học',
        teacherName: null, // No teacher
      );

      when(mockRepository.getAll()).thenAnswer((_) async => [subject]);
      await viewModel.load();

      expect(viewModel.subjects.first.teacherName, isNull);
    });

    test('should handle very long subject names', () async {
      final longName = 'A' * 500; // Very long name
      final subject = SubjectEntity(
        id: '1',
        subjectName: longName,
      );

      when(mockRepository.add(subject)).thenAnswer((_) async => {});
      when(mockRepository.getAll()).thenAnswer((_) async => [subject]);

      await viewModel.add(subject);
      expect(viewModel.subjects.first.subjectName.length, 500);
    });

    test('should handle special characters in search', () async {
      final subjects = [
        SubjectEntity(id: '1', subjectName: 'C++'),
        SubjectEntity(id: '2', subjectName: 'C#'),
        SubjectEntity(id: '3', subjectName: 'Python'),
      ];

      when(mockRepository.getAll()).thenAnswer((_) async => subjects);
      await viewModel.load();

      viewModel.updateSearchQuery('c++');
      expect(viewModel.filteredSubjects.length, 1);
      expect(viewModel.filteredSubjects.first.subjectName, 'C++');
    });

    test('should handle concurrent operations', () async {
      // Simulate concurrent add operations
      final subject1 = SubjectEntity(subjectName: 'Subject 1');
      final subject2 = SubjectEntity(subjectName: 'Subject 2');

      when(mockRepository.add(any)).thenAnswer((_) async => {});
      when(mockRepository.getAll()).thenAnswer(
        (_) async => [
          subject1.copyWith(id: '1'),
          subject2.copyWith(id: '2'),
        ],
      );

      // Execute concurrently
      await Future.wait([
        viewModel.add(subject1),
        viewModel.add(subject2),
      ]);

      // Both should be in the list (last reload wins)
      expect(viewModel.subjects.length, 2);
    });
  });
}
