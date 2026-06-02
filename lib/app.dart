import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/config/app_routes.dart';
import 'core/config/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'core/services/notification_service.dart';

// AppWidget class moved from main.dart
class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get router from AppRoutes
    final router = AppRoutes.router;
    final settingsVm = context.watch<SettingsViewModel>();
    final themeMode = settingsVm.darkMode ? ThemeMode.dark : ThemeMode.light;
    final locale = Locale(settingsVm.language);

    return MaterialApp.router(
      title: 'Student Timetable',
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
