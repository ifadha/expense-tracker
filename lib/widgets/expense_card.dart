import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';

class ExpenseCardWidget extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ExpenseCardWidget({
    super.key,
    required this.expense,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = expense.type == TransactionType.expense;
    final dateFormatted = DateFormat('dd.MM.yyyy').format(expense.date);
    final currency = AppSettingsService.instance.selectedCurrency;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: isDark ? const Color(0xFF2B374B) : Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E143C).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Direction / Category Circle Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isExpense
                        ? (isDark
                            ? const Color(0xFF202B3A)
                            : const Color(0xFFF8F9FA))
                        : (isDark
                            ? const Color(0xFF17372D)
                            : const Color(0xFFECFDF5)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isExpense
                          ? (isDark
                              ? const Color(0xFF344155)
                              : const Color(0xFFEEF0F2))
                          : (isDark
                              ? const Color(0xFF245643)
                              : const Color(0xFFD1FAE5)),
                    ),
                  ),
                  child: Icon(
                    isExpense ? Icons.north_east : Icons.south_west,
                    size: 20,
                    color: isExpense
                        ? (isDark
                            ? AppConstants.textLight
                            : const Color(0xFF475569))
                        : AppConstants.incomeGreen,
                  ),
                ),
                const SizedBox(width: 14),

                // Title and Wallet / Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppConstants.textLight
                              : AppConstants.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              expense.wallet,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppConstants.textLight
                                        .withValues(alpha: 0.7)
                                    : AppConstants.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount and Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '- ' : '+ '}$currency ${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isExpense
                            ? (isDark
                                ? AppConstants.textLight
                                : AppConstants.textDark)
                            : AppConstants.incomeGreen,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateFormatted,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppConstants.textLight.withValues(alpha: 0.7)
                            : AppConstants.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
