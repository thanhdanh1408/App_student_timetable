// lib/features/exam/presentation/widgets/exam_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/exam_entity.dart';

class ExamCard extends StatelessWidget {
  final ExamEntity exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExamCard({super.key, required this.exam, required this.onEdit, required this.onDelete});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return 'N/A';
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse color from hex string
    Color examColor = Colors.blue;
    if (exam.color != null && exam.color!.isNotEmpty) {
      try {
        examColor = Color(int.parse(exam.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        examColor = Colors.blue;
      }
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: examColor, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: examColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment,
                color: examColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.subjectName ?? "N/A",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "GV: ${exam.teacherName ?? "N/A"}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    "Kỳ thi: ${exam.examName ?? "N/A"}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    "Ngày: ${exam.examDate != null ? _formatDate(exam.examDate!) : "N/A"}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    "Giờ: ${_formatTime(exam.examTime)}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  if (exam.examRoom != null && exam.examRoom!.isNotEmpty)
                    Text(
                      "Phòng: ${exam.examRoom}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  if (exam.notes != null && exam.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Ghi chú: ${exam.notes}",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: examColor),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}