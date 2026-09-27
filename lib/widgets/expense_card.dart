import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utils/constants.dart';

class ExpenseCardWidget extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ExpenseCardWidget({
    Key? key,
    required this.expense,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'shopping_bag':
      case 'shopping_cart':
        return Icons.shopping_bag_outlined;
      case 'flight':
        return Icons.flight_takeoff;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'security':
        return Icons.verified_user_outlined;
      case 'menu_book':
        return Icons.menu_book_outlined;
      case 'campaign':
        return Icons.campaign_outlined;
      case 'wifi':
        return Icons.wifi;
      case 'water_drop':
        return Icons.water_drop_outlined;
      case 'vpn_key':
        return Icons.vpn_key_outlined;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'notifications':
        return Icons.notifications_none;
      case 'beach_access':
        return Icons.beach_access_outlined;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = AppConstants.getCategoryById(expense.categoryId);
    final categoryColor = Color(category.colorValue);
    final isExpense = expense.type == TransactionType.expense;
    final dateFormatted = DateFormat('dd.MM.yyyy').format(expense.date);
    final isCreditCard = expense.wallet.toLowerCase().contains('credit') ||
        expense.wallet.toLowerCase().contains('card');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E143C).withOpacity(0.03),
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
                        ? const Color(0xFFF8F9FA)
                        : const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isExpense
                          ? const Color(0xFFEEF0F2)
                          : const Color(0xFFD1FAE5),
                    ),
                  ),
                  child: Icon(
                    isExpense ? Icons.north_east : Icons.south_west,
                    size: 20,
                    color: isExpense ? const Color(0xFF475569) : AppConstants.incomeGreen,
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (isCreditCard) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEB001B),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-2, 0),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF79E1B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              isCreditCard ? 'MasterCard •••• 9918' : expense.wallet,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppConstants.textMuted,
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
                      '${isExpense ? '- ' : '+ '}${expense.amount.toStringAsFixed(2)} \$',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isExpense ? AppConstants.textDark : AppConstants.incomeGreen,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateFormatted,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textMuted,
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
