import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../utils/constants.dart';

class CategorySelectionScreen extends StatefulWidget {
  final String? selectedCategoryId;
  final ValueChanged<ExpenseCategory>? onCategorySelected;

  const CategorySelectionScreen({
    Key? key,
    this.selectedCategoryId,
    this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<ExpenseCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(AppConstants.defaultCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseCategory> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) return _categories;
    return _categories
        .where((cat) => cat.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

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
        return Icons.grid_view;
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    int selectedColor = 0xFF704FE6;

    final colorOptions = [
      0xFF704FE6,
      0xFF2563EB,
      0xFF16A34A,
      0xFFD97706,
      0xFFE11D48,
      0xFF06B6D4,
      0xFF8B5CF6,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Category Name',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.textMuted),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'e.g. Pet Care, Books, Coffee',
                      filled: true,
                      fillColor: const Color(0xFFF8F7FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Color',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.textMuted),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: colorOptions.map((c) {
                      final isSelected = c == selectedColor;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = c),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        final newCat = ExpenseCategory(
                          id: name.toLowerCase().replaceAll(' ', '_'),
                          name: name,
                          iconName: 'grid_view',
                          colorValue: selectedColor,
                        );

                        setState(() {
                          _categories.add(newCat);
                        });

                        Navigator.pop(context);
                        _selectCategory(newCat);
                      },
                      child: const Text('Create Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _selectCategory(ExpenseCategory category) {
    if (widget.onCategorySelected != null) {
      widget.onCategorySelected!(category);
    }
    Navigator.pop(context, category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDED7FC),
              Color(0xFFF4F2FB),
              Color(0xFFF6F5FC),
            ],
            stops: [0.0, 0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20, color: AppConstants.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search for Categories',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppConstants.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // 4-Column Category Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: _filteredCategories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Add Category Button Card
                      return GestureDetector(
                        onTap: _showAddCategoryDialog,
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppConstants.primaryPurple,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final cat = _filteredCategories[index - 1];
                    final isSelected = cat.id == widget.selectedCategoryId;
                    final color = Color(cat.colorValue);

                    return GestureDetector(
                      onTap: () => _selectCategory(cat),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected ? AppConstants.primaryPurple : Colors.white,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1E143C).withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getIconData(cat.iconName),
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: -3,
                                  right: -3,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: AppConstants.primaryPurple,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppConstants.primaryPurple : AppConstants.textDark,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
