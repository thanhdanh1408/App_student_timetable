import 'package:cloud_firestore/cloud_firestore.dart';

import '/core/services/firebase_service.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  static final NotesRepositoryImpl _instance = NotesRepositoryImpl._internal();
  factory NotesRepositoryImpl() => _instance;
  NotesRepositoryImpl._internal();

  final FirebaseService _firebase = FirebaseService();
  List<NoteEntity>? _cache;
  DateTime? _cacheAt;
  String? _cachedUserId;

  bool get _isCacheFresh =>
      _cache != null &&
      _cacheAt != null &&
      _cachedUserId == _firebase.currentUserId &&
      DateTime.now().difference(_cacheAt!).inSeconds < 60;

  CollectionReference<Map<String, dynamic>> get _notesCollection => _firebase
      .firestore
      .collection('users')
      .doc(_firebase.currentUserId)
      .collection('notes');

  @override
  Future<List<NoteEntity>> getAll() async {
    try {
      if (_isCacheFresh) {
        return List<NoteEntity>.from(_cache!);
      }

      if (!_firebase.isAuthenticated || _firebase.currentUserId == null) {
        return [];
      }

      final snapshot = await _notesCollection.orderBy('updated_at', descending: true).get();
      final notes = snapshot.docs.map((doc) {
        final data = doc.data();
        data['note_id'] = doc.id;
        return NoteEntity.fromJson(data);
      }).toList();
      _cache = notes;
      _cacheAt = DateTime.now();
      _cachedUserId = _firebase.currentUserId;
      return notes;
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }

  @override
  Future<String> add(NoteEntity note) async {
    if (!_firebase.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    final now = DateTime.now();
    final doc = await _notesCollection.add({
      'title': note.title,
      'content': note.content,
      'subject_id': note.subjectId,
      'subject_name': note.subjectName,
      'tags': note.tags,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    _cache = null;
    _cacheAt = null;
    return doc.id;
  }

  @override
  Future<void> update(NoteEntity note) async {
    if (!_firebase.isAuthenticated) {
      throw Exception('Not authenticated');
    }
    if (note.id == null) {
      throw Exception('Note id cannot be null');
    }

    await _notesCollection.doc(note.id!).update({
      'title': note.title,
      'content': note.content,
      'subject_id': note.subjectId,
      'subject_name': note.subjectName,
      'tags': note.tags,
      'updated_at': DateTime.now().toIso8601String(),
    });
    _cache = null;
    _cacheAt = null;
  }

  @override
  Future<void> delete(String id) async {
    if (!_firebase.isAuthenticated) {
      throw Exception('Not authenticated');
    }
    await _notesCollection.doc(id).delete();
    _cache = null;
    _cacheAt = null;
  }
}
