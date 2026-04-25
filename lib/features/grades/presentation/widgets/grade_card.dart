import 'package:flutter/material.dart';

import '../../domain/entities/grade_entity.dart';

class GradeCard extends StatelessWidget {
  final GradeEntity grade;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GradeCard({
    super.key,
    required this.grade,
    required this.onEdit,
    required this.onDelete,
  });

  Color _gradeColor(double score10) {
    if (score10 >= 8) return Colors.green;
    if (score10 >= 6.5) return Colors.orange;
    if (score10 >= 5) return Colors.amber[700]!;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(grade.score10);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    grade.subjectName ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${grade.score10.toStringAsFixed(1)} / ${grade.letterGrade}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Sửa')),
                    PopupMenuItem(value: 'delete', child: Text('Xóa')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Tín chỉ: ${grade.credit} • Hệ 4: ${grade.score4.toStringAsFixed(2)}'),
            if (grade.note != null && grade.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Ghi chú: ${grade.note}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
