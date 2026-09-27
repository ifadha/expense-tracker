import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/constants.dart';

class CategorySelectorWidget extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback? onOpenFullPicker;

  const CategorySelectorWidget({
    Key? key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.onOpenFullPicker,
  }) : super(key: key);

  IconData _getIconData(String iconName) {
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
    final categories = AppConstants.defaultCategories;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + (onOpenFullPicker != null ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return OutlinedButton.icon(
              onPressed: onOpenFullPicker,
              icon: const Icon(Icons.add, size: 14),
              label: const Text('More'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.textMuted,
                side: BorderSide(color: Colors.grey.shade300, style: BorderStyle.solid),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            );
          }

          final cat = categories[index];
          final isSelected = cat.id == selectedCategoryId;
          final color = Color(cat.colorValue);

          return InkWell(
            onTap: () => onCategorySelected(cat.id),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppConstants.primaryPurple : Colors.white,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppConstants.primaryPurple.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconData(cat.iconName),
                    size: 15,
                    color: isSelected ? AppConstants.primaryPurple : color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppConstants.primaryPurple : AppConstants.textDark,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check,
                      size: 13,
                      color: AppConstants.primaryPurple,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
