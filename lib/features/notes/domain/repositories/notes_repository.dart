import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getAll();
  Future<String> add(NoteEntity note);
  Future<void> update(NoteEntity note);
  Future<void> delete(String id);
}
