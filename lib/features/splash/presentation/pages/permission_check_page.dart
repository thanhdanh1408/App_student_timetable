
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

class PermissionCheckPage extends StatefulWidget {
  const PermissionCheckPage({super.key});

  @override
  State<PermissionCheckPage> createState() => _PermissionCheckPageState();
}

class _PermissionCheckPageState extends State<PermissionCheckPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Thêm timeout 5 giây để đảm bảo app không bao giờ bị treo vĩnh viễn
      Future.any([
        _checkAndRequestPermissions(),
        Future.delayed(const Duration(seconds: 5)),
      ]).then((_) {
        if (mounted) _navigateToNextScreen();
      });
    });
  }

  Future<void> _checkAndRequestPermissions() async {
    if (kIsWeb) return;

    // KHÔNG request Permission.notification ở đây.
    // flutter_local_notifications v17+ tự động xử lý quyền thông báo
    // trong quá trình initialize() ở main(). Request thêm sẽ gây xung đột.

    // Chỉ request Calendar permission (không liên quan đến NotificationService)
    // Đợi 800ms để NotificationService hoàn tất request permission của nó trước
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    try {
      final calendarStatus = await Permission.calendar.status;
      if (calendarStatus.isDenied) {
        await Permission.calendar.request();
      }
    } catch (e) {
      // Bỏ qua lỗi permission để app không bị treo
      debugPrint('⚠️ Calendar permission request failed: $e');
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
