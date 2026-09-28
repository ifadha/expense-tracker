// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumina_expense_tracker/models/expense.dart';
import 'package:lumina_expense_tracker/services/settings_service.dart';
import 'package:lumina_expense_tracker/utils/constants.dart';

// ignore: subtype_of_sealed_class
class _FakeDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  _FakeDocumentSnapshot(this._data);

  final Map<String, dynamic>? _data;
  @override
  String get id => 'expense-1';

  @override
  bool get exists => _data != null;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic get(Object field) => _data?[field];

  @override
  dynamic operator [](Object field) => get(field);

  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('expense serializes and deserializes its Firestore fields', () {
    final date = DateTime(2026, 9, 28);
    final expense = Expense(
      id: 'expense-1',
      title: '  Groceries  ',
      amount: 42.5,
      category: 'food',
      date: date,
      note: '  Weekly shop  ',
      type: TransactionType.expense,
    );

    final data = expense.toFirestore();
    final restored = Expense.fromFirestore(
      _FakeDocumentSnapshot({
        ...data,
        'date': Timestamp.fromDate(date),
      }),
    );

    expect(data['title'], 'Groceries');
    expect(data['date'], '2026-09-28');
    expect(restored.id, 'expense-1');
    expect(restored.title, 'Groceries');
    expect(restored.amount, 42.5);
    expect(restored.date, date);
    expect(restored.note, 'Weekly shop');
  });

  test('expense rejects missing or malformed Firestore dates', () {
    expect(
      () => Expense.fromFirestore(_FakeDocumentSnapshot({})),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => Expense.fromFirestore(
        _FakeDocumentSnapshot({'date': 'not-a-date'}),
      ),
      throwsA(isA<FormatException>()),
    );
  });

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
