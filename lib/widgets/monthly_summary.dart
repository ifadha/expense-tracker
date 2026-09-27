import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MonthlySummaryWidget extends StatelessWidget {
  final double totalSpend;
  final double totalBudget;
  final int percentageChange;
  final bool isBelowLastMonth;
  final String monthName;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthlySummaryWidget({
    Key? key,
    required this.totalSpend,
    required this.totalBudget,
    required this.percentageChange,
    required this.isBelowLastMonth,
    required this.monthName,
    required this.onPreviousMonth,
    required this.onNextMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final budgetPercent = totalBudget > 0
        ? ((totalSpend / totalBudget) * 100).clamp(0, 100).toInt()
        : 0;

    return Column(
      children: [
        // Month Selector Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
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
                color: Colors.blueGrey[700],
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppConstants.primaryPurple,
              ),
              const SizedBox(width: 6),
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: onNextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                color: Colors.blueGrey[700],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Big Metric Display
        const Text(
          'This Month Spend',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppConstants.textMuted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${totalSpend.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppConstants.textDark,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),

        // Trend Pill
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBelowLastMonth ? Icons.trending_down : Icons.trending_up,
              size: 15,
              color: isBelowLastMonth ? AppConstants.incomeGreen : AppConstants.expenseRed,
            ),
            const SizedBox(width: 4),
            Text(
              '$percentageChange% ${isBelowLastMonth ? 'below' : 'above'} last month',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppConstants.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Monthly Budget Progress Bar Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.7)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Monthly Budget',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textDark,
                    ),
                  ),
                  Text(
                    '\$${totalSpend.toStringAsFixed(0)} / \$${totalBudget.toStringAsFixed(0)} ($budgetPercent%)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (totalSpend / totalBudget).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    budgetPercent > 90
                        ? AppConstants.expenseRed
                        : (budgetPercent > 75 ? Colors.amber : AppConstants.primaryPurple),
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
