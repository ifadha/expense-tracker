import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SpendingChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const SpendingChartWidget({
    super.key,
    required this.monthlyData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppConstants.textLight : AppConstants.textDark;
    double maxVal = 100.0;
    for (final d in monthlyData) {
      final inc = (d['income'] as num).toDouble();
      final exp = (d['expense'] as num).toDouble();
      if (inc > maxVal) maxVal = inc;
      if (exp > maxVal) maxVal = exp;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E143C).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row with Timeframe & Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF101827)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? const Color(0xFF283449)
                          : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Monthly',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 16, color: AppConstants.textMuted),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildLegendDot(AppConstants.primaryPurple, 'Income'),
                  const SizedBox(width: 12),
                  _buildLegendDot(AppConstants.chartLime, 'Expense'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dual Bars
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyData.map((d) {
                final income = (d['income'] as num).toDouble();
                final expense = (d['expense'] as num).toDouble();
                final incomeRatio =
                    income <= 0 ? 0.0 : (income / maxVal).clamp(0.1, 1.0);
                final expenseRatio =
                    expense <= 0 ? 0.0 : (expense / maxVal).clamp(0.1, 1.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Expense Bar (Lime)
                        Container(
                          width: 8,
                          height: 120 * expenseRatio,
                          decoration: BoxDecoration(
                            color: AppConstants.chartLime,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Income Bar (Purple)
                        Container(
                          width: 8,
                          height: 120 * incomeRatio,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      d['month'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppConstants.textLight.withValues(alpha: 0.7)
                            : AppConstants.textMuted,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppConstants.textMuted,
          ),
        ),
      ],
    );
  }
}
