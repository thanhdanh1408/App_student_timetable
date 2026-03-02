
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
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    // Permission handler không hoạt động trên web
    if (kIsWeb) {
      _navigateToNextScreen();
      return;
    }
    
    final a = await Permission.notification.isDenied;
    final b = await Permission.calendar.isDenied;
    if (a || b) {
      await [
        Permission.notification,
        Permission.calendar,
      ].request();
    }
    _navigateToNextScreen();

  }

  void _navigateToNextScreen() {
    // Chuyển đến màn hình chính sau khi kiểm tra quyền
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
