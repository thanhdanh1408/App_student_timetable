import 'package:flutter_test/flutter_test.dart';
import 'package:student_timetable_app/features/notes/domain/entities/note_entity.dart';

void main() {
  group('NoteEntity', () {
    test('fromJson parses expected fields', () {
      final json = {
        'note_id': 'n1',
        'title': 'CTDL',
        'content': 'On tap complexity',
        'subject_id': 's1',
        'subject_name': 'Cau truc du lieu',
        'tags': ['midterm', 'week1'],
        'created_at': '2026-04-25T09:00:00.000Z',
        'updated_at': '2026-04-25T10:00:00.000Z',
      };

      final entity = NoteEntity.fromJson(json);

      expect(entity.id, 'n1');
      expect(entity.title, 'CTDL');
      expect(entity.subjectName, 'Cau truc du lieu');
      expect(entity.tags, ['midterm', 'week1']);
      expect(entity.content, contains('complexity'));
    });

    test('toJson keeps data integrity', () {
      final entity = NoteEntity(
        id: 'n2',
        title: 'Ghi chu',
        content: 'Noi dung',
        subjectId: 's2',
        subjectName: 'Toan roi rac',
        tags: const ['quiz'],
        createdAt: DateTime.parse('2026-04-25T09:00:00.000Z'),
        updatedAt: DateTime.parse('2026-04-25T10:00:00.000Z'),
      );

      final json = entity.toJson();

      expect(json['note_id'], 'n2');
      expect(json['title'], 'Ghi chu');
      expect(json['subject_name'], 'Toan roi rac');
      expect(json['tags'], ['quiz']);
      expect(json['created_at'], '2026-04-25T09:00:00.000Z');
    });

    test('copyWith updates selected fields only', () {
      final original = NoteEntity(
        id: 'n3',
        title: 'Title',
        content: 'Content',
        subjectId: 's3',
        subjectName: 'Subject',
        tags: const ['a'],
        createdAt: DateTime.parse('2026-04-25T09:00:00.000Z'),
        updatedAt: DateTime.parse('2026-04-25T10:00:00.000Z'),
      );

      final updated = original.copyWith(title: 'Updated', tags: const ['a', 'b']);

      expect(updated.id, 'n3');
      expect(updated.title, 'Updated');
      expect(updated.content, 'Content');
      expect(updated.tags, ['a', 'b']);
      expect(updated.subjectName, 'Subject');
    });
  });
}
