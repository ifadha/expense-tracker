import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import 'home/home_screen.dart';
import 'expenses/expense_history_screen.dart';
import 'expenses/add_expense_screen.dart';
import 'analytics/analytics_screen.dart';
import 'account/account_screen.dart';

class MainNavScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const MainNavScreen({
    Key? key,
    required this.expenseService,
  }) : super(key: key);

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(expenseService: widget.expenseService),
      ExpenseHistoryScreen(expenseService: widget.expenseService),
      AnalyticsScreen(expenseService: widget.expenseService),
      AccountScreen(expenseService: widget.expenseService),
    ];
  }

  void _openAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(expenseService: widget.expenseService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
        color: Colors.transparent,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E143C).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.receipt_long_outlined, Icons.receipt_long, 'Transactions'),
              
              // Elevated Center FAB
              GestureDetector(
                onTap: _openAddExpense,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryDark,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryDark.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),

              _buildNavItem(2, Icons.bar_chart_outlined, Icons.bar_chart, 'Analytics'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Account'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? AppConstants.primaryPurple : AppConstants.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppConstants.primaryPurple : AppConstants.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
