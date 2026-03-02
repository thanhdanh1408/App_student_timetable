// test/unit/domain/entities/subject_entity_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:student_timetable_app/features/subjects/domain/entities/subject_entity.dart';

void main() {
  group('SubjectEntity', () {
    test('should create a SubjectEntity with all fields', () {
      // Arrange & Act
      final subject = SubjectEntity(
        id: '123',
        subjectName: 'Lập trình di động',
        teacherName: 'Nguyễn Văn A',
        color: '#FF5733',
        credit: 3,
      );

      // Assert
      expect(subject.id, '123');
      expect(subject.subjectName, 'Lập trình di động');
      expect(subject.teacherName, 'Nguyễn Văn A');
      expect(subject.color, '#FF5733');
      expect(subject.credit, 3);
    });

    test('should create a SubjectEntity with only required fields', () {
      // Arrange & Act
      final subject = SubjectEntity(
        subjectName: 'Cơ sở dữ liệu',
      );

      // Assert
      expect(subject.id, isNull);
      expect(subject.subjectName, 'Cơ sở dữ liệu');
      expect(subject.teacherName, isNull);
      expect(subject.color, isNull);
      expect(subject.credit, isNull);
    });

    test('should create SubjectEntity from JSON', () {
      // Arrange
      final json = {
        'subject_id': '456',
        'subject_name': 'Mạng máy tính',
        'teacher_name': 'Trần Thị B',
        'color': '#33C1FF',
        'credit': 4,
      };

      // Act
      final subject = SubjectEntity.fromJson(json);

      // Assert
      expect(subject.id, '456');
      expect(subject.subjectName, 'Mạng máy tính');
      expect(subject.teacherName, 'Trần Thị B');
      expect(subject.color, '#33C1FF');
      expect(subject.credit, 4);
    });

    test('should handle null values in JSON', () {
      // Arrange
      final json = {
        'subject_name': 'Toán cao cấp',
      };

      // Act
      final subject = SubjectEntity.fromJson(json);

      // Assert
      expect(subject.subjectName, 'Toán cao cấp');
      expect(subject.id, isNull);
      expect(subject.teacherName, isNull);
      expect(subject.color, isNull);
      expect(subject.credit, isNull);
    });

    test('copyWith should update only specified fields', () {
      // Arrange
      final original = SubjectEntity(
        id: '789',
        subjectName: 'Vật lý',
        teacherName: 'Lê Văn C',
        color: '#75FF33',
        credit: 2,
      );

      // Act
      final updated = original.copyWith(
        subjectName: 'Vật lý đại cương',
        credit: 3,
      );

      // Assert
      expect(updated.id, '789'); // Không đổi
      expect(updated.subjectName, 'Vật lý đại cương'); // Đã đổi
      expect(updated.teacherName, 'Lê Văn C'); // Không đổi
      expect(updated.color, '#75FF33'); // Không đổi
      expect(updated.credit, 3); // Đã đổi
    });

    test('copyWith should keep original values when no parameters provided', () {
      // Arrange
      final original = SubjectEntity(
        id: '999',
        subjectName: 'Hóa học',
        teacherName: 'Phạm Thị D',
        color: '#FF33E6',
        credit: 3,
      );

      // Act
      final copied = original.copyWith();

      // Assert
      expect(copied.id, original.id);
      expect(copied.subjectName, original.subjectName);
      expect(copied.teacherName, original.teacherName);
      expect(copied.color, original.color);
      expect(copied.credit, original.credit);
    });
  });
}
