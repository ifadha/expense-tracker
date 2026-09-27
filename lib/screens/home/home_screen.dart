import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../utils/constants.dart';
import '../../widgets/monthly_summary.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/edit_expense_screen.dart';
import '../expenses/expense_history_screen.dart';

class HomeScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const HomeScreen({
    Key? key,
    required this.expenseService,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(2026, 9);
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
            stops: [0.0, 0.35, 1.0],
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
              final totalSpend = widget.expenseService.calculateMonthTotal(expenses);

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top Navigation Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircularButton(
                            icon: Icons.tune,
                            onTap: () {},
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.8)),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppConstants.textDark,
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
                        totalBudget: 3200.0,
                        percentageChange: 67,
                        isBelowLastMonth: true,
                        monthName: monthName,
                        onPreviousMonth: _previousMonth,
                        onNextMonth: _nextMonth,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Spending Wallet Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E143C).withOpacity(0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F0FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppConstants.primaryPurple,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Spending Wallet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppConstants.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Active Checking',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppConstants.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              '\$5,631.22',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppConstants.textDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppConstants.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Recent Transactions Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppConstants.textDark,
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
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppConstants.textMuted,
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: EmptyStateWidget(
                          title: 'No expenses for $monthName',
                          description: 'Record an expense to see it in your monthly overview.',
                          onAction: () => _openAddExpense(context),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddExpense(context),
        backgroundColor: AppConstants.primaryDark,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _openAddExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(expenseService: widget.expenseService),
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

  Widget _buildCircularButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: AppConstants.textDark,
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
