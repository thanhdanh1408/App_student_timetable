import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  void _go(BuildContext context, String path) {
    Navigator.of(context).pop();
    if (currentRoute != path) {
      context.go(path);
    }
  }

  Widget _item({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String path,
  }) {
    final selected = currentRoute == path;
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.indigo : null),
      title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : null)),
      selected: selected,
      onTap: () => _go(context, path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'Student Timetable',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _item(context: context, icon: Icons.home, label: 'Trang chủ', path: '/home'),
            _item(context: context, icon: Icons.book, label: 'Môn học', path: '/subjects'),
            _item(context: context, icon: Icons.calendar_today, label: 'Lịch học', path: '/schedule'),
            _item(context: context, icon: Icons.assignment, label: 'Lịch thi', path: '/exam'),
            _item(context: context, icon: Icons.notifications, label: 'Thông báo', path: '/notification'),
            _item(context: context, icon: Icons.school, label: 'Quản lý điểm', path: '/grades'),
            _item(context: context, icon: Icons.checklist, label: 'To-do', path: '/tasks'),
            const Divider(height: 1),
            _item(context: context, icon: Icons.settings, label: 'Cài đặt', path: '/settings'),
          ],
        ),
      ),
    );
  }
}
