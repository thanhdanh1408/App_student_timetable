import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class UpdateNoteUsecase {
  final NotesRepository _repository;

  UpdateNoteUsecase(this._repository);

  Future<void> call(NoteEntity note) {
    return _repository.update(note);
  }
}
