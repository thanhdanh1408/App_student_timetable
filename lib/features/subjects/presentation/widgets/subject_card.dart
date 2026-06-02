// lib/features/subjects/presentation/widgets/subject_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/subject_entity.dart';
import 'delete_confirm_dialog.dart';
import '/core/l10n/app_localizations.dart';

class SubjectCard extends StatelessWidget {
  final SubjectEntity subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Parse color from hex string
    Color subjectColor = Colors.blue;
    if (subject.color != null) {
      try {
        subjectColor = Color(int.parse(subject.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        subjectColor = Colors.blue;
      }
    }
    
    final l = AppLocalizations.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: subjectColor, width: 6),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: subjectColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.book, color: subjectColor, size: 28),
          ),
          title: Text(
            subject.subjectName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (subject.teacherName != null && subject.teacherName!.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${subject.teacherName}"),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.credit_card, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(l.isVietnamese ? "${subject.credit} tín chỉ" : "${subject.credit} credits"),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.indigo),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteConfirmDialog(
                      subjectName: subject.subjectName,
                      onConfirm: onDelete,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}