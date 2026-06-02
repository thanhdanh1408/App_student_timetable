import 'package:home_widget/home_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Service to update the Android home-screen widget with today's schedule.
class WidgetService {
  static const _androidWidgetName = 'TodayScheduleWidget';

  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// Fetch today's schedule from Firestore and push data to the native widget.
  Future<void> updateWidget() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        await _pushEmptyWidget('Chưa đăng nhập');
        return;
      }

      final todayIndex = DateTime.now().weekday + 1; // Mon=2 .. Sun=8
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('schedules')
          .where('day_of_week', isEqualTo: todayIndex)
          .get();

      if (snapshot.docs.isEmpty) {
        await _pushEmptyWidget('Không có lịch học hôm nay');
        return;
      }

      // Sort by start_time
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aTime = a.data()['start_time'] ?? '';
          final bTime = b.data()['start_time'] ?? '';
          return aTime.compareTo(bTime);
        });

      // Build summary lines (max 4)
      final lines = <String>[];
      final maxItems = docs.length > 4 ? 4 : docs.length;
      for (var i = 0; i < maxItems; i++) {
        final data = docs[i].data();
        final subjectName = data['subject_name'] ?? 'N/A';
        final startTime = data['start_time'] ?? '';
        final endTime = data['end_time'] ?? '';
        final location = data['location'] ?? '';
        lines.add('$startTime-$endTime  $subjectName  ($location)');
      }

      if (docs.length > 4) {
        lines.add('... và ${docs.length - 4} buổi khác');
      }

      final today = DateFormat('EEEE, dd/MM').format(DateTime.now());

      await HomeWidget.saveWidgetData<String>('widget_title', 'Lịch học hôm nay');
      await HomeWidget.saveWidgetData<String>('widget_date', today);
      await HomeWidget.saveWidgetData<String>('widget_schedule', lines.join('\n'));
      await HomeWidget.saveWidgetData<int>('widget_count', docs.length);

      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
      );
    } catch (e) {
      await _pushEmptyWidget('Lỗi: $e');
    }
  }

  Future<void> _pushEmptyWidget(String message) async {
    final today = DateFormat('EEEE, dd/MM').format(DateTime.now());
    await HomeWidget.saveWidgetData<String>('widget_title', 'Lịch học hôm nay');
    await HomeWidget.saveWidgetData<String>('widget_date', today);
    await HomeWidget.saveWidgetData<String>('widget_schedule', message);
    await HomeWidget.saveWidgetData<int>('widget_count', 0);
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
    );
  }
}
