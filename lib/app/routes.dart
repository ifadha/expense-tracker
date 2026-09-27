import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../screens/main_nav_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/expenses/expense_history_screen.dart';
import '../screens/expenses/category_selection_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/account/account_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addExpense = '/add-expense';
  static const String history = '/history';
  static const String analytics = '/analytics';
  static const String categories = '/categories';
  static const String account = '/account';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    ExpenseService service, [
    Object? settingsService,
  ]) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
            builder: (_) => MainNavScreen(expenseService: service));
      case addExpense:
        return MaterialPageRoute(
            builder: (_) => AddExpenseScreen(expenseService: service));
      case history:
        return MaterialPageRoute(
            builder: (_) => ExpenseHistoryScreen(expenseService: service));
      case analytics:
        return MaterialPageRoute(
            builder: (_) => AnalyticsScreen(expenseService: service));
      case categories:
        return MaterialPageRoute(
            builder: (_) => const CategorySelectionScreen());
      case account:
        return MaterialPageRoute(
            builder: (_) => AccountScreen(expenseService: service));
      default:
        return MaterialPageRoute(
            builder: (_) => MainNavScreen(expenseService: service));
    }
  }
}
