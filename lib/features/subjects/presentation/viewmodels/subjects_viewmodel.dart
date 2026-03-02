import 'package:flutter/material.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/usecases/get_subjects_usecase.dart';
import '../../domain/usecases/add_subject_usecase.dart';
import '../../domain/usecases/update_subject_usecase.dart';
import '../../domain/usecases/delete_subject_usecase.dart';

class SubjectsViewModel with ChangeNotifier {
  final GetSubjectsUsecase _get;
  final AddSubjectUsecase _add;
  final UpdateSubjectUsecase _update;
  final DeleteSubjectUsecase _delete;

  SubjectsViewModel({
    required GetSubjectsUsecase get,
    required AddSubjectUsecase add,
    required UpdateSubjectUsecase update,
    required DeleteSubjectUsecase delete,
  })  : _get = get,
        _add = add,
        _update = update,
        _delete = delete;

  // Model (Data)
  List<SubjectEntity> _subjects = [];
  bool _isLoading = false;
  String? _error;
  
  // UI State (MVVM)
  String _searchQuery = '';
  
  // Getters (Data Binding)
  List<SubjectEntity> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  
  // Computed Property (Data Binding - filtered list)
  List<SubjectEntity> get filteredSubjects {
    if (_searchQuery.isEmpty) return _subjects;
    return _subjects.where((s) => 
      s.subjectName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (s.teacherName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }
  
  // Commands (MVVM)
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _subjects = await _get();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(SubjectEntity s) async {
    try {
      await _add(s);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> update(SubjectEntity s) async {
    try {
      await _update(s);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete(id);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Kiểm tra tên môn học đã tồn tại chưa
  /// Trả về true nếu tên đã tồn tại (trùng)
  bool checkDuplicateSubjectName(String name, {String? excludeId}) {
    final trimmedName = name.trim().toLowerCase();
    return _subjects.any((s) => 
      s.id != excludeId && 
      s.subjectName.trim().toLowerCase() == trimmedName
    );
  }
}

// Backward-compatible alias (old naming used across the UI).
