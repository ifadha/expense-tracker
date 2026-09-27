import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../utils/constants.dart';
import '../../widgets/spending_chart.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/error_state.dart';

class AnalyticsScreen extends StatelessWidget {
  final ExpenseService expenseService;

  const AnalyticsScreen({
    Key? key,
    required this.expenseService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppConstants.textDark,
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
            final totalExpense = expenseService.calculateMonthTotal(expenses, type: TransactionType.expense);
            final totalIncome = expenseService.calculateMonthTotal(expenses, type: TransactionType.income);

            // Chart data
            final chartData = [
              {'month': 'Feb', 'income': 4200.0, 'expense': 3100.0},
              {'month': 'Mar', 'income': 4500.0, 'expense': 2800.0},
              {'month': 'Apr', 'income': 4100.0, 'expense': 3450.0},
              {'month': 'May', 'income': 5200.0, 'expense': 3200.0},
              {'month': 'Jun', 'income': 4800.0, 'expense': 2900.0},
              {'month': 'Jul', 'income': totalIncome > 0 ? totalIncome : 5600.0, 'expense': totalExpense > 0 ? totalExpense : 3800.0},
            ];

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
                          color: const Color(0xFFFAF8FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1EBFB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0E8FE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.savings_outlined, color: AppConstants.primaryPurple, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${totalIncome.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppConstants.textDark),
                                  ),
                                  const Text('Income', style: TextStyle(fontSize: 11, color: AppConstants.textMuted)),
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
                          color: const Color(0xFFF7FDF7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE6F4EA)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7ED),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.receipt_outlined, color: AppConstants.incomeGreen, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${totalExpense.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppConstants.textDark),
                                  ),
                                  const Text('Expenses', style: TextStyle(fontSize: 11, color: AppConstants.textMuted)),
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
                const Text(
                  'Top Categories',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppConstants.textDark),
                ),
                const SizedBox(height: 12),

                ...AppConstants.defaultCategories.take(4).map((cat) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                                color: Color(cat.colorValue).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.category, color: Color(cat.colorValue), size: 16),
                            ),
                            const SizedBox(width: 10),
                            Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Text('Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppConstants.primaryPurple)),
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
