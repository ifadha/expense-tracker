import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../services/settings_service.dart';
import '../../utils/constants.dart';
import '../../widgets/spending_chart.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/error_state.dart';

class AnalyticsScreen extends StatelessWidget {
  final ExpenseService expenseService;

  const AnalyticsScreen({
    super.key,
    required this.expenseService,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.backgroundDark : AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppConstants.textLight : AppConstants.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppConstants.textLight : AppConstants.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Expense>>(
          stream: expenseService.watchAllExpenses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingStateWidget();
            }

            if (snapshot.hasError) {
              return ErrorStateWidget(errorMessage: snapshot.error.toString());
            }

            final expenses = snapshot.data ?? [];
            final totalExpense = expenseService.calculateMonthTotal(expenses,
                type: TransactionType.expense);
            final totalIncome = expenseService.calculateMonthTotal(expenses,
                type: TransactionType.income);
            final currency = AppSettingsService.instance.selectedCurrency;
            final now = DateTime.now();
            final chartData = List<Map<String, dynamic>>.generate(6, (index) {
              final month = DateTime(now.year, now.month - 5 + index);
              final monthExpenses = expenses.where(
                (expense) =>
                    expense.date.year == month.year &&
                    expense.date.month == month.month,
              );
              return {
                'month': DateFormat('MMM').format(month),
                'income': expenseService.calculateMonthTotal(
                  monthExpenses.toList(),
                  type: TransactionType.income,
                ),
                'expense': expenseService.calculateMonthTotal(
                  monthExpenses.toList(),
                  type: TransactionType.expense,
                ),
              };
            });
            final categoryTotals = <String, double>{};
            for (final expense in expenses
                .where((item) => item.type == TransactionType.expense)) {
              categoryTotals.update(
                expense.categoryId,
                (total) => total + expense.amount,
                ifAbsent: () => expense.amount,
              );
            }
            final topCategories = categoryTotals.entries.toList()
              ..sort((first, second) => second.value.compareTo(first.value));

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                // Chart Card
                SpendingChartWidget(monthlyData: chartData),
                const SizedBox(height: 16),

                // Income & Expense Metric Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppConstants.cardDark
                              : const Color(0xFFFAF8FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2B374B)
                                  : const Color(0xFFF1EBFB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF302B43)
                                    : const Color(0xFFF0E8FE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.savings_outlined,
                                  color: AppConstants.primaryPurple, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$currency ${totalIncome.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppConstants.textLight
                                            : AppConstants.textDark),
                                  ),
                                  Text('Income',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppConstants.textLight
                                                  .withValues(alpha: 0.7)
                                              : AppConstants.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppConstants.cardDark
                              : const Color(0xFFF7FDF7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2B374B)
                                  : const Color(0xFFE6F4EA)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF17372D)
                                    : const Color(0xFFE8F7ED),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.receipt_outlined,
                                  color: AppConstants.incomeGreen, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$currency ${totalExpense.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppConstants.textLight
                                            : AppConstants.textDark),
                                  ),
                                  Text('Expenses',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppConstants.textLight
                                                  .withValues(alpha: 0.7)
                                              : AppConstants.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Top Spending Categories
                Text(
                  'Top Categories',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppConstants.textLight
                          : AppConstants.textDark),
                ),
                const SizedBox(height: 12),

                if (topCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No spending recorded yet.',
                      style: TextStyle(
                          color: isDark
                              ? AppConstants.textLight.withValues(alpha: 0.7)
                              : AppConstants.textMuted),
                    ),
                  )
                else
                  ...topCategories.take(4).map((entry) {
                    final category = AppConstants.getCategoryById(entry.key);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppConstants.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(category.colorValue)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.category,
                                    color: Color(category.colorValue),
                                    size: 16),
                              ),
                              const SizedBox(width: 10),
                              Text(category.name,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppConstants.textLight
                                          : AppConstants.textDark)),
                            ],
                          ),
                          Text('$currency ${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppConstants.primaryPurple)),
                        ],
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}
