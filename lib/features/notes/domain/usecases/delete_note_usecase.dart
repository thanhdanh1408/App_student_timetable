import '../repositories/notes_repository.dart';

class DeleteNoteUsecase {
  final NotesRepository _repository;

  DeleteNoteUsecase(this._repository);

  Future<void> call(String id) {
    return _repository.delete(id);
  }
}
