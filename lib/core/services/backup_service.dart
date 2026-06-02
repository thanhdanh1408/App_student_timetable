import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

/// Service to backup and restore all user data from/to Firestore.
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  static const _collections = [
    'subjects',
    'schedules',
    'exams',
    'notifications',
    'settings',
    'grades',
    'tasks',
    'notes',
  ];

  /// Export all user data to a JSON file and return the File.
  Future<File> exportBackup() async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final data = <String, dynamic>{
      'app': 'Student Timetable',
      'version': '2.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'user_id': userId,
    };

    for (final collection in _collections) {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(collection)
          .get();

      data[collection] = snapshot.docs.map((doc) {
        final docData = doc.data();
        docData['__doc_id__'] = doc.id;
        return docData;
      }).toList();
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/backup_$timestamp.json');
    await file.writeAsString(jsonString, flush: true);
    return file;
  }

  /// Share the backup file.
  Future<void> shareBackup() async {
    final file = await exportBackup();
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Student Timetable Backup',
    );
  }

  /// Pick a backup JSON file and restore data to Firestore.
  /// Returns the number of documents restored.
  Future<int> importBackup() async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('Không có file nào được chọn');
    }

    final filePath = result.files.single.path;
    if (filePath == null) throw Exception('Không thể đọc file');

    final jsonString = await File(filePath).readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Validate backup file
    if (data['app'] != 'Student Timetable') {
      throw Exception('File backup không hợp lệ');
    }

    int count = 0;
    WriteBatch batch = _firestore.batch();
    int batchCount = 0;

    for (final collection in _collections) {
      final items = data[collection] as List<dynamic>?;
      if (items == null) continue;

      for (final item in items) {
        final docData = Map<String, dynamic>.from(item as Map);
        final docId = docData.remove('__doc_id__') as String?;

        final ref = docId != null
            ? _firestore
                .collection('users')
                .doc(userId)
                .collection(collection)
                .doc(docId)
            : _firestore
                .collection('users')
                .doc(userId)
                .collection(collection)
                .doc();

        batch.set(ref, docData, SetOptions(merge: true));
        count++;
        batchCount++;

        // Firestore batch limit is 500 operations
        if (batchCount >= 499) {
          await batch.commit();
          batch = _firestore.batch();
          batchCount = 0;
        }
      }
    }

    // Commit remaining operations
    if (batchCount > 0) {
      await batch.commit();
    }
    return count;
  }
}
