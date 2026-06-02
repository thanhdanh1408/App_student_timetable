// lib/features/settings/presentation/widgets/notification_settings_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/l10n/app_localizations.dart';
import '/core/providers/notification_settings_provider.dart';

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final notificationSettings = context.watch<NotificationSettingsProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Thông báo lịch học
          ListTile(
            leading: const Icon(Icons.school, color: Colors.blue),
            title: Text(l.isVietnamese ? "Thông báo lịch học" : "Schedule notifications"),
            subtitle: Text(
              notificationSettings.enableScheduleNotifications
                  ? (l.isVietnamese ? "Nhắc " : "Remind ") + notificationSettings.getReminderText(notificationSettings.scheduleReminderMinutes, isVietnamese: l.isVietnamese)
                  : (l.isVietnamese ? "Đã tắt" : "Disabled")
            ),
            trailing: Switch(
              value: notificationSettings.enableScheduleNotifications,
              onChanged: (value) {
                notificationSettings.setEnableScheduleNotifications(value);
              },
            ),
          ),
          if (notificationSettings.enableScheduleNotifications) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(l.isVietnamese ? "Nhắc trước:" : "Remind before:"),
                  const Spacer(),
                  DropdownButton<int>(
                    value: notificationSettings.scheduleReminderMinutes,
                    items: NotificationSettingsProvider.reminderOptions.map((minutes) {
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text(notificationSettings.getReminderText(minutes, isVietnamese: l.isVietnamese)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        notificationSettings.setScheduleReminderMinutes(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 1),
          // Thông báo lịch thi
          ListTile(
            leading: const Icon(Icons.assignment, color: Colors.orange),
            title: Text(l.isVietnamese ? "Thông báo lịch thi" : "Exam notifications"),
            subtitle: Text(
              notificationSettings.enableExamNotifications
                  ? (l.isVietnamese ? "Nhắc " : "Remind ") + notificationSettings.getReminderText(notificationSettings.examReminderMinutes, isVietnamese: l.isVietnamese)
                  : (l.isVietnamese ? "Đã tắt" : "Disabled")
            ),
            trailing: Switch(
              value: notificationSettings.enableExamNotifications,
              onChanged: (value) {
                notificationSettings.setEnableExamNotifications(value);
              },
            ),
          ),
          if (notificationSettings.enableExamNotifications) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(l.isVietnamese ? "Nhắc trước:" : "Remind before:"),
                  const Spacer(),
                  DropdownButton<int>(
                    value: notificationSettings.examReminderMinutes,
                    items: NotificationSettingsProvider.reminderOptions.map((minutes) {
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text(notificationSettings.getReminderText(minutes, isVietnamese: l.isVietnamese)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        notificationSettings.setExamReminderMinutes(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
