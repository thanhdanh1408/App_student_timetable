import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/schedule_entity.dart';

class ScheduleExportService {
  static const Map<int, String> _dayMap = {
    2: 'Thứ 2',
    3: 'Thứ 3',
    4: 'Thứ 4',
    5: 'Thứ 5',
    6: 'Thứ 6',
    7: 'Thứ 7',
    8: 'Chủ nhật',
  };

  /// Load a TTF font from assets for Vietnamese Unicode support in PDFs.
  Future<pw.Font> _loadFont(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return pw.Font.ttf(data);
  }

  Future<File> exportPdf(List<ScheduleEntity> schedules) async {
    final sorted = _sortSchedules(schedules);
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Load Vietnamese-compatible fonts
    final regularFont = await _loadFont('assets/fonts/Roboto-Regular.ttf');
    final boldFont = await _loadFont('assets/fonts/Roboto-Bold.ttf');

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'Thời Khoá Biểu',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Ngày xuất: $now',
            style: pw.TextStyle(font: regularFont),
          ),
          pw.SizedBox(height: 16),
          if (sorted.isEmpty)
            pw.Text(
              'Chưa có dữ liệu lịch học.',
              style: pw.TextStyle(font: regularFont),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Thứ', 'Môn học', 'Giảng viên', 'Giờ', 'Địa điểm'],
              data: sorted
                  .map(
                    (s) => [
                      _dayMap[s.dayOfWeek] ?? '-',
                      s.subjectName ?? '-',
                      s.teacherName ?? '-',
                      '${s.startTime ?? '--:--'} - ${s.endTime ?? '--:--'}',
                      s.location ?? '-',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                font: boldFont,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: pw.TextStyle(
                font: regularFont,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(6),
              border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.6),
            ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/schedule_export.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<File> exportIcs(List<ScheduleEntity> schedules) async {
    final sorted = _sortSchedules(schedules);
    final nowUtc = DateTime.now().toUtc();

    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//Student Timetable App//VI//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');

    for (final schedule in sorted) {
      final start = _nextDateTimeForSchedule(schedule.dayOfWeek, schedule.startTime);
      final end = _nextDateTimeForSchedule(schedule.dayOfWeek, schedule.endTime);
      if (start == null || end == null) continue;

      final uid = '${schedule.id ?? schedule.subjectId ?? start.millisecondsSinceEpoch}@student-timetable';
      final summary = _escapeIcsText(schedule.subjectName ?? 'Lịch học');
      final description = _escapeIcsText(
        'Giảng viên: ${schedule.teacherName ?? '-'}\\nGhi chú: ${schedule.notes ?? '-'}',
      );
      final location = _escapeIcsText(schedule.location ?? '-');

      buffer.writeln('BEGIN:VEVENT');
      buffer.writeln('UID:$uid');
      buffer.writeln('DTSTAMP:${_formatIcsDateTime(nowUtc)}');
      buffer.writeln('DTSTART:${_formatIcsDateTime(start.toUtc())}');
      buffer.writeln('DTEND:${_formatIcsDateTime(end.toUtc())}');
      buffer.writeln('RRULE:FREQ=WEEKLY;COUNT=16');
      buffer.writeln('SUMMARY:$summary');
      buffer.writeln('DESCRIPTION:$description');
      buffer.writeln('LOCATION:$location');
      buffer.writeln('END:VEVENT');
    }

    buffer.writeln('END:VCALENDAR');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/schedule_export.ics');
    await file.writeAsString(buffer.toString(), flush: true);
    return file;
  }

  Future<void> shareFiles(List<File> files, {String? text}) async {
    final xfiles = files.map((f) => XFile(f.path)).toList();
    await Share.shareXFiles(xfiles, text: text ?? 'Lịch học từ Student Timetable App');
  }

  List<ScheduleEntity> _sortSchedules(List<ScheduleEntity> schedules) {
    final sorted = List<ScheduleEntity>.from(schedules);
    sorted.sort((a, b) {
      final dayCompare = (a.dayOfWeek ?? 99).compareTo(b.dayOfWeek ?? 99);
      if (dayCompare != 0) return dayCompare;
      return (a.startTime ?? '').compareTo(b.startTime ?? '');
    });
    return sorted;
  }

  DateTime? _nextDateTimeForSchedule(int? dayOfWeek, String? time) {
    if (dayOfWeek == null || time == null || !time.contains(':')) return null;

    final parts = time.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    final now = DateTime.now();
    final targetWeekday = dayOfWeek == 8 ? DateTime.sunday : dayOfWeek - 1;
    var diff = targetWeekday - now.weekday;
    if (diff < 0) diff += 7;

    final date = DateTime(now.year, now.month, now.day).add(Duration(days: diff));
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _formatIcsDateTime(DateTime dt) {
    return DateFormat("yyyyMMdd'T'HHmmss'Z'").format(dt);
  }

  String _escapeIcsText(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll(';', r'\;')
        .replaceAll(',', r'\,')
        .replaceAll('\n', r'\n');
  }
}
