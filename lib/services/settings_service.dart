import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class AppSettingsService extends ChangeNotifier {
  static const String _currencyKey = 'selected_currency';
  static const String _budgetKey = 'monthly_budget';
  static const String _themeKey = 'dark_mode';

  AppSettingsService._internal();
  static final AppSettingsService instance = AppSettingsService._internal();

  late SharedPreferences _prefs;

  String _selectedCurrency = AppConstants.defaultCurrency;
  double _monthlyBudget = AppConstants.defaultMonthlyBudget;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  String get selectedCurrency => _selectedCurrency;
  double get monthlyBudget => _monthlyBudget;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _selectedCurrency =
        _prefs.getString(_currencyKey) ?? AppConstants.defaultCurrency;
    _monthlyBudget =
        _prefs.getDouble(_budgetKey) ?? AppConstants.defaultMonthlyBudget;
    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  bool isCurrencySupported(String symbol) {
    return AppConstants.currencyOptions
        .any((option) => option['symbol'] == symbol);
  }

  Future<void> setSelectedCurrency(String symbol) async {
    final normalized = symbol.trim();
    if (normalized.isEmpty || !isCurrencySupported(normalized)) {
      return;
    }

    _selectedCurrency = normalized;
    await _prefs.setString(_currencyKey, normalized);
    notifyListeners();
  }

  Future<double> setMonthlyBudget(double value) async {
    final sanitized =
        value.isFinite && value > 0 ? value : AppConstants.defaultMonthlyBudget;
    _monthlyBudget = sanitized;
    await _prefs.setDouble(_budgetKey, sanitized);
    notifyListeners();
    return _monthlyBudget;
  }

  Future<void> setDarkMode(bool enabled) async {
    _isDarkMode = enabled;
    await _prefs.setBool(_themeKey, enabled);
    notifyListeners();
  }

  String formatAmount(double value,
      {bool includeSign = false, bool includeSymbol = true}) {
    final symbol = _selectedCurrency;
    final safeAmount = value.isFinite ? value.abs() : 0.0;
    final formattedValue = NumberFormat('#,##0.00', 'en_US').format(safeAmount);

    if (!includeSymbol) {
      if (includeSign) {
        final sign = value >= 0 ? '+' : '-';
        return '$sign$formattedValue';
      }
      return formattedValue;
    }

    if (includeSign) {
      final sign = value >= 0 ? '+' : '-';
      return '$sign $symbol $formattedValue';
    }

    return '$symbol $formattedValue';
  }
}
