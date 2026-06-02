import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class GetNotesUsecase {
  final NotesRepository _repository;

  GetNotesUsecase(this._repository);

  Future<List<NoteEntity>> call() {
    return _repository.getAll();
  }
}
