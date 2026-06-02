// lib/core/config/app_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/providers/auth_provider.dart' as auth;
import '/features/authentication/presentation/pages/login_page.dart';
import '/features/authentication/presentation/pages/register_page.dart';
import '/features/home/presentation/pages/home_page.dart';
import '/features/subjects/presentation/pages/subjects_page.dart';
import '/features/schedule/presentation/pages/schedule_page.dart';
import '/features/exam/presentation/pages/exam_page.dart';
import '/features/settings/presentation/pages/settings_page.dart';
import '/features/notifications/presentation/pages/notification_page.dart';
import '/features/splash/presentation/pages/permission_check_page.dart';
import '/features/grades/presentation/pages/grades_page.dart';
import '/features/tasks/presentation/pages/tasks_page.dart';
import '/features/notes/presentation/pages/notes_page.dart';

class _BottomNavShell extends StatelessWidget {
  final Widget child;
  const _BottomNavShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<auth.AuthProvider>(
      builder: (context, authProvider, _) {
        return child;
      },
    );
  }
}

GoRouter _createAppRouter(auth.AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isSplashPage = state.uri.path == '/splash';
      if(isSplashPage) return null;
      final isLoginPage = state.uri.path == '/login';
      final isRegisterPage = state.uri.path == '/register';

      // Nếu chưa login, redirect về /login
      if (!isLoggedIn && !isLoginPage && !isRegisterPage) {
        return '/login';
      }

      // Nếu đã login nhưng đang ở login/register page, redirect về /home
      if (isLoggedIn && (isLoginPage || isRegisterPage)) {
        return '/home';
      }

      return null;
    },
    refreshListenable: authProvider,
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const PermissionCheckPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      ShellRoute(
        builder: (_, __, child) => _BottomNavShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/subjects', builder: (_, __) => const SubjectsPage()),
          GoRoute(path: '/schedule', builder: (_, __) => const SchedulePage()),
          GoRoute(path: '/exam', builder: (_, __) => const ExamPage()),
          GoRoute(path: '/notification', builder: (_, __) => const NotificationPage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/grades', builder: (_, __) => const GradesPage()),
          GoRoute(path: '/tasks', builder: (_, __) => const TasksPage()),
          GoRoute(path: '/notes', builder: (_, __) => const NotesPage()),
        ],
      ),
    ],
  );
}

class AppRoutes {
  static late final GoRouter router;

  static void initialize(auth.AuthProvider authProvider) {
    router = _createAppRouter(authProvider);
  }
}