import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import 'theme.dart';
import 'routes.dart';

class LuminaExpenseApp extends StatelessWidget {
  final ExpenseService expenseService;

  const LuminaExpenseApp({
    Key? key,
    required this.expenseService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(settings, expenseService),
    );
  }
}
