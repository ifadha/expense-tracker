import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MonthlySummaryWidget extends StatelessWidget {
  final double totalSpend;
  final double totalBudget;
  final String currencySymbol;
  final String monthName;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthlySummaryWidget({
    super.key,
    required this.totalSpend,
    required this.totalBudget,
    required this.currencySymbol,
    required this.monthName,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final budgetPercent = totalBudget > 0
        ? ((totalSpend / totalBudget) * 100).clamp(0, 100).toInt()
        : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Month Selector Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A2333)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: isDark
                    ? const Color(0xFF283449)
                    : Colors.white.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                onPressed: onPreviousMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                color: isDark ? AppConstants.textLight : Colors.blueGrey[700],
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppConstants.primaryPurple,
              ),
              const SizedBox(width: 6),
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? AppConstants.textLight : AppConstants.textDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: onNextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                color: isDark ? AppConstants.textLight : Colors.blueGrey[700],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Big Metric Display
        Text(
          'This Month Spend',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppConstants.textLight.withValues(alpha: 0.7)
                : AppConstants.textMuted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$currencySymbol ${totalSpend.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: isDark ? AppConstants.textLight : AppConstants.textDark,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),

        const SizedBox(height: 20),

        // Monthly Budget Progress Bar Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A2333)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark
                    ? const Color(0xFF283449)
                    : Colors.white.withValues(alpha: 0.7)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Budget',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppConstants.textLight
                          : AppConstants.textDark,
                    ),
                  ),
                  Text(
                    '$currencySymbol ${totalSpend.toStringAsFixed(0)} / $currencySymbol ${totalBudget.toStringAsFixed(0)} ($budgetPercent%)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppConstants.textLight.withValues(alpha: 0.7)
                          : AppConstants.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: totalBudget > 0
                      ? (totalSpend / totalBudget).clamp(0.0, 1.0)
                      : 0,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? const Color(0xFF283449)
                      : const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    budgetPercent > 90
                        ? AppConstants.expenseRed
                        : (budgetPercent > 75
                            ? Colors.amber
                            : AppConstants.primaryPurple),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
