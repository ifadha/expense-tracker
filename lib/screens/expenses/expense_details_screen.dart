import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../utils/constants.dart';
import 'edit_expense_screen.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final ExpenseService expenseService;
  final Expense expense;

  const ExpenseDetailsScreen({
    Key? key,
    required this.expenseService,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = AppConstants.getCategoryById(expense.categoryId);
    final isExpense = expense.type == TransactionType.expense;

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
          'Transaction Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppConstants.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppConstants.primaryPurple),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => EditExpenseScreen(
                    expenseService: expenseService,
                    expense: expense,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Amount Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E143C).withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(category.colorValue).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpense ? Icons.north_east : Icons.south_west,
                        color: Color(category.colorValue),
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      expense.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${isExpense ? '- ' : '+ '}\$${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isExpense ? AppConstants.expenseRed : AppConstants.incomeGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detail Rows
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildRow('Category', category.name),
                    const Divider(height: 24),
                    _buildRow('Date', DateFormat('dd MMMM yyyy').format(expense.date)),
                    const Divider(height: 24),
                    _buildRow('Payment Account', expense.wallet),
                    if (expense.note != null && expense.note!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildRow('Note', expense.note!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppConstants.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppConstants.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
