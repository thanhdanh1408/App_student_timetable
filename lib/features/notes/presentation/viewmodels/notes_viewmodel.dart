import 'package:flutter/material.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/add_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';

class NotesViewModel with ChangeNotifier {
  final GetNotesUsecase _get;
  final AddNoteUsecase _add;
  final UpdateNoteUsecase _update;
  final DeleteNoteUsecase _delete;

  NotesViewModel({
    required GetNotesUsecase get,
    required AddNoteUsecase add,
    required UpdateNoteUsecase update,
    required DeleteNoteUsecase delete,
  })  : _get = get,
        _add = add,
        _update = update,
        _delete = delete;

  List<NoteEntity> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<NoteEntity> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String _friendlyError(Object e) {
    final raw = e.toString();
    if (raw.contains('permission-denied')) {
      return '[cloud_firestore/permission-denied] Notes chưa có quyền truy cập. Hãy deploy Firestore rules mới: firebase deploy --only firestore:rules';
    }
    return raw;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _get();
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(NoteEntity note) async {
    try {
      await _add(note);
      await load();
    } catch (e) {
      _error = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> update(NoteEntity note) async {
    try {
      await _update(note);
      await load();
    } catch (e) {
      _error = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete(id);
      await load();
    } catch (e) {
      _error = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }
}
