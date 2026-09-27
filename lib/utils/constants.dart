import 'package:flutter/material.dart';
import '../models/category.dart';

class AppConstants {
  static const String appName = 'Lumina Expense Tracker';
  static const String expensesCollection = 'expenses';
  static const String defaultCurrency = '\$';
    static const double defaultMonthlyBudget = 0.0;

  static const List<Map<String, String>> currencyOptions = [
    {'symbol': '\$', 'name': 'USD (\$)'},
    {'symbol': '€', 'name': 'EUR (€)'},
    {'symbol': '£', 'name': 'GBP (£)'},
    {'symbol': '¥', 'name': 'JPY (¥)'},
    {'symbol': '₹', 'name': 'INR (₹)'},
    {'symbol': 'C\$', 'name': 'CAD (C\$)'},
    {'symbol': 'Rs.', 'name': 'LKR (Rs.)'},
  ];

  // Primary Theme Colors (from primary reference design)
  static const Color primaryPurple = Color(0xFF704FE6);
  static const Color primaryDark = Color(0xFF1B1433);
  static const Color backgroundLight = Color(0xFFF6F5FC);
  static const Color backgroundLavender = Color(0xFFDED7FC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1A2333);
  static const Color surfaceDark = Color(0xFF101827);
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF17122B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFE2E8F0);
  static const Color expenseRed = Color(0xFFFF4866);
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color chartLime = Color(0xFF84CC16);

  // Default Categories
  static const List<ExpenseCategory> defaultCategories = [
    ExpenseCategory(
        id: 'groceries',
        name: 'Groceries',
        iconName: 'shopping_bag',
        colorValue: 0xFF16A34A),
    ExpenseCategory(
        id: 'travel',
        name: 'Travel',
        iconName: 'flight',
        colorValue: 0xFF06B6D4),
    ExpenseCategory(
        id: 'car',
        name: 'Car',
        iconName: 'directions_car',
        colorValue: 0xFF2563EB),
    ExpenseCategory(
        id: 'home', name: 'Home', iconName: 'home', colorValue: 0xFFDB2777),
    ExpenseCategory(
        id: 'insurance',
        name: 'Insurances',
        iconName: 'security',
        colorValue: 0xFF0D9488),
    ExpenseCategory(
        id: 'education',
        name: 'Education',
        iconName: 'menu_book',
        colorValue: 0xFF7C3AED),
    ExpenseCategory(
        id: 'marketing',
        name: 'Marketing',
        iconName: 'campaign',
        colorValue: 0xFFD97706),
    ExpenseCategory(
        id: 'shopping',
        name: 'Shopping',
        iconName: 'shopping_cart',
        colorValue: 0xFF059669),
    ExpenseCategory(
        id: 'internet',
        name: 'Internet',
        iconName: 'wifi',
        colorValue: 0xFF8B5CF6),
    ExpenseCategory(
        id: 'water',
        name: 'Water',
        iconName: 'water_drop',
        colorValue: 0xFF0284C7),
    ExpenseCategory(
        id: 'rent', name: 'Rent', iconName: 'vpn_key', colorValue: 0xFFEA580C),
    ExpenseCategory(
        id: 'gym',
        name: 'Gym',
        iconName: 'fitness_center',
        colorValue: 0xFFCA8A04),
    ExpenseCategory(
        id: 'subscription',
        name: 'Subscription',
        iconName: 'notifications',
        colorValue: 0xFF9333EA),
    ExpenseCategory(
        id: 'vacation',
        name: 'Vacation',
        iconName: 'beach_access',
        colorValue: 0xFF10B981),
    ExpenseCategory(
        id: 'dining',
        name: 'Food & Dining',
        iconName: 'restaurant',
        colorValue: 0xFFE11D48),
    ExpenseCategory(
        id: 'other',
        name: 'Other',
        iconName: 'grid_view',
        colorValue: 0xFF6366F1),
  ];

  static ExpenseCategory getCategoryById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => const ExpenseCategory(
        id: 'other',
        name: 'Other',
        iconName: 'grid_view',
        colorValue: 0xFF6366F1,
      ),
    );
  }
}
