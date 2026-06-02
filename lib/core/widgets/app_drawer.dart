import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/l10n/app_localizations.dart';

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
    final l = AppLocalizations.of(context);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                l.appTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _item(context: context, icon: Icons.home, label: l.home, path: '/home'),
            _item(context: context, icon: Icons.book, label: l.subjects, path: '/subjects'),
            _item(context: context, icon: Icons.calendar_today, label: l.schedule, path: '/schedule'),
            _item(context: context, icon: Icons.assignment, label: l.exam, path: '/exam'),
            _item(context: context, icon: Icons.notifications, label: l.notifications, path: '/notification'),
            _item(context: context, icon: Icons.school, label: l.grades, path: '/grades'),
            _item(context: context, icon: Icons.checklist, label: l.tasks, path: '/tasks'),
            _item(context: context, icon: Icons.notes, label: l.notes, path: '/notes'),
            const Divider(height: 1),
            _item(context: context, icon: Icons.settings, label: l.settings, path: '/settings'),
          ],
        ),
      ),
    );
  }
}
