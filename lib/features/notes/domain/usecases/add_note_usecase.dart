import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class AddNoteUsecase {
  final NotesRepository _repository;

  AddNoteUsecase(this._repository);

  Future<String> call(NoteEntity note) {
    return _repository.add(note);
  }
}
