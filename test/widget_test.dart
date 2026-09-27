// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumina_expense_tracker/services/settings_service.dart';
import 'package:lumina_expense_tracker/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('currency, budget, and theme settings persist', () async {
    SharedPreferences.setMockInitialValues({});
    final settingsService = AppSettingsService.instance;
    await settingsService.init();

    await settingsService.setSelectedCurrency('Rs.');
    await settingsService.setMonthlyBudget(125000);
    await settingsService.setDarkMode(true);

    await settingsService.init();

    expect(settingsService.selectedCurrency, 'Rs.');
    expect(settingsService.monthlyBudget, 125000);
    expect(settingsService.isDarkMode, isTrue);
  });

  test('unsupported currency is ignored and invalid budget is sanitized',
      () async {
    SharedPreferences.setMockInitialValues({});
    final settingsService = AppSettingsService.instance;
    await settingsService.init();

    for (final currency in AppConstants.currencyOptions) {
      expect(settingsService.isCurrencySupported(currency['symbol']!), isTrue);
    }
    expect(settingsService.isCurrencySupported('XYZ'), isFalse);

    await settingsService.setSelectedCurrency('XYZ');
    final savedBudget = await settingsService.setMonthlyBudget(0);

    expect(settingsService.selectedCurrency, AppConstants.defaultCurrency);
    expect(savedBudget, AppConstants.defaultMonthlyBudget);
  });
}
