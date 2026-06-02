// lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/core/providers/auth_provider.dart';
import '/core/services/notification_service.dart';
import '/core/services/backup_service.dart';
import '/core/l10n/app_localizations.dart';
import '/core/widgets/app_drawer.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/notification_settings_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Consumer2<AuthProvider, SettingsViewModel>(
      builder: (context, auth, settingsVm, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l.settings, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: const AppDrawer(currentRoute: '/settings'),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              children: [
                // Thông tin người dùng
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.isVietnamese ? 'Thông tin tài khoản' : 'Account information',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.indigo,
                              child: Text(
                                (auth.userEmail?.isNotEmpty ?? false)
                                    ? auth.userEmail![0].toUpperCase()
                                    : 'S',
                                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    auth.userEmail?.split('@').first ?? (l.isVietnamese ? 'Sinh viên' : 'Student'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    auth.userEmail ?? "",
                                    style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // CÀI ĐẶT THÔNG BÁO
            Text(l.notifications, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            const NotificationSettingsCard(),

            // Cài đặt chung
            Text(l.general, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  // TEST NOTIFICATION BUTTON
                  ListTile(
                    leading: const Icon(Icons.notifications_active, color: Colors.orange),
                    title: const Text("🧪 Test Notification"),
                    subtitle: Text(l.isVietnamese ? "Nhấn để kiểm tra thông báo" : "Tap to test notification"),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () async {
                        try {
                          print('🧪 Testing notification...');
                          await NotificationService().showImmediateNotification(
                            id: 'test_notification_9999',
                            title: '🧪 Test Notification',
                            body: 'Hệ thống thông báo đang hoạt động!',
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l.isVietnamese ? '✅ Đã gửi thông báo thử nghiệm!' : '✅ Test notification sent!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          print('❌ Error testing notification: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l.isVietnamese ? '❌ Lỗi: $e' : '❌ Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Test', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l.language),
                    subtitle: Text(settingsVm.language == 'en' ? 'English' : 'Tiếng Việt'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        builder: (_) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.language),
                                title: const Text('Tiếng Việt'),
                                onTap: () => Navigator.pop(context, 'vi'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.language),
                                title: const Text('English'),
                                onTap: () => Navigator.pop(context, 'en'),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (selected != null) {
                        await settingsVm.setLanguage(selected);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: Text(l.darkMode),
                    trailing: Switch(
                      value: settingsVm.darkMode,
                      onChanged: (value) => settingsVm.setDarkMode(value),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(l.notifications),
                    trailing: Switch(
                      value: settingsVm.notifications,
                      onChanged: (value) => settingsVm.setNotifications(value),
                    ),
                  ),
                ],
              ),
            ),

            // Backup & Restore
            const SizedBox(height: 8),
            Text(l.dataSection, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_download, color: Colors.blue),
                    title: Text(l.backup),
                    subtitle: Text(l.backupDesc),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      try {
                        final file = await BackupService().exportBackup();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.isVietnamese ? '✅ Đã sao lưu: ${file.path}' : '✅ Backup saved: ${file.path}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.isVietnamese ? '❌ Lỗi sao lưu: $e' : '❌ Backup error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.teal),
                    title: Text(l.shareBackup),
                    subtitle: Text(l.shareBackupDesc),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      try {
                        await BackupService().shareBackup();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.isVietnamese ? '❌ Lỗi: $e' : '❌ Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload, color: Colors.orange),
                    title: Text(l.restore),
                    subtitle: Text(l.restoreDesc),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          icon: const Icon(Icons.restore, color: Colors.orange, size: 48),
                          title: Text(l.restoreConfirm),
                          content: Text(l.restoreWarning),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: Text(l.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: Text(l.restore),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      try {
                        final count = await BackupService().importBackup();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.isVietnamese ? '✅ Đã khôi phục $count mục dữ liệu!' : '✅ Restored $count items!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.isVietnamese ? '❌ Lỗi khôi phục: $e' : '❌ Restore error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            // Giới thiệu
            Text(l.about, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: Text(l.about),
                    subtitle: const Text("Version 2.0.0"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Student Timetable",
                        applicationVersion: "2.0.0",
                        applicationLegalese: "© 2024 Student Timetable",
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: Text(l.isVietnamese ? "Chính sách bảo mật" : "Privacy Policy"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l.isVietnamese ? "Chính sách bảo mật" : "Privacy Policy"),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: SingleChildScrollView(
                              child: Text(
                                l.isVietnamese
                                    ? '''Cập nhật lần cuối: 28/04/2026

1. Thu thập dữ liệu
Ứng dụng Student Timetable thu thập các thông tin sau:
• Địa chỉ email đăng nhập (qua Google hoặc email/mật khẩu).
• Dữ liệu lịch học, lịch thi, môn học và ghi chú do bạn tạo.
• Cài đặt ứng dụng (ngôn ngữ, chế độ tối, tuỳ chọn thông báo).

2. Mục đích sử dụng
Dữ liệu được sử dụng để:
• Đồng bộ lịch học giữa các thiết bị qua Firebase.
• Gửi thông báo nhắc lịch học và lịch thi.
• Cải thiện trải nghiệm người dùng.

3. Lưu trữ và bảo mật
• Dữ liệu được lưu trữ trên Google Firebase với mã hoá truyền tải (TLS).
• Mỗi người dùng chỉ có thể truy cập dữ liệu của chính mình.
• Chúng tôi không bán, chia sẻ hay cung cấp dữ liệu cho bên thứ ba.

4. Quyền truy cập thiết bị
Ứng dụng yêu cầu các quyền sau:
• Thông báo: để gửi nhắc nhở lịch học/thi.
• Internet: để đồng bộ dữ liệu với Firebase.
• Bộ nhớ: để xuất/nhập file backup và PDF.

5. Quyền của người dùng
Bạn có quyền:
• Xoá tài khoản và toàn bộ dữ liệu bất kỳ lúc nào.
• Xuất dữ liệu cá nhân qua chức năng sao lưu.
• Tắt thông báo trong phần cài đặt.

6. Liên hệ
Nếu có thắc mắc về chính sách bảo mật, vui lòng liên hệ qua email: support@studenttimetable.app'''
                                    : '''Last updated: 04/28/2026

1. Data Collection
The Student Timetable app collects the following information:
• Login email address (via Google or email/password).
• Schedule, exam, subject, and note data that you create.
• App settings (language, dark mode, notification preferences).

2. Purpose of Use
Your data is used to:
• Sync schedules across devices via Firebase.
• Send schedule and exam reminder notifications.
• Improve the user experience.

3. Storage and Security
• Data is stored on Google Firebase with transport encryption (TLS).
• Each user can only access their own data.
• We do not sell, share, or provide data to third parties.

4. Device Permissions
The app requests the following permissions:
• Notifications: to send schedule/exam reminders.
• Internet: to sync data with Firebase.
• Storage: to export/import backup files and PDFs.

5. User Rights
You have the right to:
• Delete your account and all data at any time.
• Export your personal data via the backup feature.
• Disable notifications in settings.

6. Contact
If you have questions about the privacy policy, please contact us at: support@studenttimetable.app''',
                                style: const TextStyle(fontSize: 14, height: 1.5),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l.isVietnamese ? 'Đóng' : 'Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(l.isVietnamese ? "Điều khoản sử dụng" : "Terms of Service"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l.isVietnamese ? "Điều khoản sử dụng" : "Terms of Service"),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: SingleChildScrollView(
                              child: Text(
                                l.isVietnamese
                                    ? '''Cập nhật lần cuối: 28/04/2026

1. Chấp nhận điều khoản
Bằng việc sử dụng ứng dụng Student Timetable, bạn đồng ý tuân thủ các điều khoản dưới đây. Nếu không đồng ý, vui lòng ngừng sử dụng ứng dụng.

2. Mô tả dịch vụ
Student Timetable là ứng dụng quản lý thời khoá biểu dành cho sinh viên, bao gồm:
• Quản lý lịch học, lịch thi và môn học.
• Nhắc nhở thông báo tự động.
• Sao lưu và khôi phục dữ liệu.
• Xuất lịch học dưới dạng PDF và iCal.

3. Tài khoản người dùng
• Bạn cần đăng ký tài khoản để sử dụng ứng dụng.
• Bạn chịu trách nhiệm bảo mật thông tin đăng nhập.
• Mỗi tài khoản chỉ dành cho một người dùng.

4. Quy tắc sử dụng
Khi sử dụng ứng dụng, bạn cam kết:
• Không sử dụng ứng dụng cho mục đích bất hợp pháp.
• Không cố gắng truy cập trái phép vào hệ thống.
• Không phát tán nội dung vi phạm pháp luật.

5. Giới hạn trách nhiệm
• Ứng dụng được cung cấp "nguyên trạng" (as-is).
• Chúng tôi không chịu trách nhiệm về mất mát dữ liệu do lỗi thiết bị hoặc mạng.
• Chúng tôi có quyền thay đổi hoặc ngừng dịch vụ bất kỳ lúc nào.

6. Sở hữu trí tuệ
• Mọi nội dung, thiết kế và mã nguồn của ứng dụng thuộc quyền sở hữu của nhóm phát triển.
• Bạn không được sao chép, phân phối hoặc chỉnh sửa ứng dụng mà không có sự cho phép.

7. Thay đổi điều khoản
Chúng tôi có quyền cập nhật điều khoản sử dụng. Thay đổi sẽ có hiệu lực ngay khi được đăng tải trên ứng dụng.

8. Liên hệ
Nếu có thắc mắc về điều khoản sử dụng, vui lòng liên hệ qua email: support@studenttimetable.app'''
                                    : '''Last updated: 04/28/2026

1. Acceptance of Terms
By using the Student Timetable app, you agree to comply with the following terms. If you do not agree, please stop using the app.

2. Description of Service
Student Timetable is a timetable management app for students, including:
• Managing class schedules, exams, and subjects.
• Automatic reminder notifications.
• Data backup and restore.
• Exporting schedules as PDF and iCal.

3. User Accounts
• You need to register an account to use the app.
• You are responsible for keeping your login information secure.
• Each account is intended for a single user.

4. Usage Rules
When using the app, you agree to:
• Not use the app for illegal purposes.
• Not attempt unauthorized access to the system.
• Not distribute content that violates the law.

5. Limitation of Liability
• The app is provided "as-is".
• We are not responsible for data loss due to device or network errors.
• We reserve the right to modify or discontinue the service at any time.

6. Intellectual Property
• All content, design, and source code of the app are owned by the development team.
• You may not copy, distribute, or modify the app without permission.

7. Changes to Terms
We reserve the right to update the terms of service. Changes will take effect immediately upon posting in the app.

8. Contact
If you have questions about the terms of service, please contact us at: support@studenttimetable.app''',
                                style: const TextStyle(fontSize: 14, height: 1.5),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l.isVietnamese ? 'Đóng' : 'Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nút đăng xuất
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      icon: const Icon(Icons.logout, color: Colors.red, size: 48),
                      title: Text(l.logOut),
                      content: Text(l.logOutConfirm),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            Navigator.pop(context);
                            await context.read<AuthProvider>().signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          child: Text(l.logOut, style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: Text(l.logOut),
              ),
            ),

            const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
