import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/expense_service.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import 'theme.dart';
import 'routes.dart';

class LuminaExpenseApp extends StatelessWidget {
  final ExpenseService expenseService;
  final AppSettingsService settingsService;

  const LuminaExpenseApp({
    super.key,
    required this.expenseService,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsService,
      builder: (context, _) {
        final isDark = settingsService.isDarkMode;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor:
                isDark ? AppConstants.backgroundDark : Colors.white,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            initialRoute: AppRoutes.home,
            onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
                settings, expenseService, settingsService),
          ),
        );
      },
    );
  }
}
