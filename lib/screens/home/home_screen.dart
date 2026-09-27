import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../services/settings_service.dart';
import '../../utils/constants.dart';
import '../../widgets/monthly_summary.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../expenses/edit_expense_screen.dart';
import '../expenses/expense_history_screen.dart';

class HomeScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const HomeScreen({
    super.key,
    required this.expenseService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppSettingsService _settings = AppSettingsService.instance;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_handleSettingsChanged);
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  void _handleSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _settings.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);
    final currency = _settings.selectedCurrency;
    final monthlyBudget = _settings.monthlyBudget;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.backgroundDark : AppConstants.backgroundLight,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF111827),
                    const Color(0xFF172033),
                    const Color(0xFF111827),
                  ]
                : [
                    const Color(0xFFDED7FC),
                    const Color(0xFFF4F2FB),
                    const Color(0xFFF6F5FC),
                  ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Expense>>(
            stream: widget.expenseService.watchExpensesForMonth(
              _selectedMonth.year,
              _selectedMonth.month,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingStateWidget();
              }

              if (snapshot.hasError) {
                return ErrorStateWidget(
                  errorMessage: snapshot.error.toString(),
                  onRetry: () => setState(() {}),
                );
              }

              final expenses = snapshot.data ?? [];
              final totalSpend =
                  widget.expenseService.calculateMonthTotal(expenses);

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top Navigation Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircularButton(
                            icon: _settings.isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            onTap: () async {
                              await _settings
                                  .setDarkMode(!_settings.isDarkMode);
                              if (mounted) setState(() {});
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A2333)
                                  : Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF2B374B)
                                      : Colors.white.withValues(alpha: 0.8)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: AppConstants.primaryPurple,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('E, d MMM').format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppConstants.textLight
                                        : AppConstants.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildCircularButton(
                            icon: Icons.notifications_none,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hero Spending Summary
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MonthlySummaryWidget(
                        totalSpend: totalSpend,
                        totalBudget: monthlyBudget,
                        currencySymbol: currency,
                        monthName: monthName,
                        onPreviousMonth: _previousMonth,
                        onNextMonth: _nextMonth,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Recent Transactions Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppConstants.textLight
                                  : AppConstants.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExpenseHistoryScreen(
                                    expenseService: widget.expenseService,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppConstants.textLight
                                        .withValues(alpha: 0.8)
                                    : AppConstants.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent Transactions List or Empty State
                  if (expenses.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: EmptyStateWidget(
                          title: 'No expenses for $monthName',
                          description:
                              'Record an expense to see it in your monthly overview.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final expense = expenses[index];
                            return ExpenseCardWidget(
                              expense: expense,
                              onTap: () => _openEditExpense(context, expense),
                            );
                          },
                          childCount: expenses.length > 5 ? 5 : expenses.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openEditExpense(BuildContext context, Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditExpenseScreen(
          expenseService: widget.expenseService,
          expense: expense,
        ),
      ),
    );
  }

  Widget _buildCircularButton(
      {required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? AppConstants.cardDark
            : Colors.white.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border:
            Border.all(color: isDark ? const Color(0xFF2B374B) : Colors.white),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: isDark ? AppConstants.textLight : AppConstants.textDark,
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
