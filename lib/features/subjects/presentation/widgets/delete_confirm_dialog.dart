// lib/features/subjects/presentation/widgets/delete_confirm_dialog.dart
import 'package:flutter/material.dart';
import '/core/l10n/app_localizations.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final String subjectName;
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({
    super.key,
    required this.subjectName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
      title: Text(l.isVietnamese ? "Xác nhận xóa" : "Confirm delete", style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(l.isVietnamese ? "Bạn có chắc muốn xóa môn học:\n\n\"$subjectName\"?\n\nHành động này không thể hoàn tác!" : "Are you sure you want to delete the subject:\n\n\"$subjectName\"?\n\nThis action cannot be undone!"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel, style: const TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(l.delete, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}