import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../utils/constants.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import 'edit_expense_screen.dart';
import 'add_expense_screen.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const ExpenseHistoryScreen({
    super.key,
    required this.expenseService,
  });

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  TransactionType? _typeFilter;
  DateTime? _dateFilter;
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppConstants.textLight : AppConstants.textDark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.backgroundDark : AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search,
                color: textColor),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchQuery = '';
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: textColor),
            onPressed: _pickDateFilter,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            if (_showSearch)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: TextField(
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search merchant, note, or amount...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

            // Segmented Type Pills (All, Deposit, Withdrawal)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildTypeTab('All', null),
                  const SizedBox(width: 8),
                  _buildTypeTab('Deposit of funds', TransactionType.income),
                  const SizedBox(width: 8),
                  _buildTypeTab('Withdrawal of funds', TransactionType.expense),
                ],
              ),
            ),

            // Category Chips Row
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCategoryChip('All Categories', 'all'),
                  ...AppConstants.defaultCategories.map((c) {
                    return _buildCategoryChip(c.name, c.id);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Transactions Stream
            Expanded(
              child: StreamBuilder<List<Expense>>(
                stream: widget.expenseService.watchAllExpenses(),
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

                  var list = snapshot.data ?? [];

                  // Apply type filter
                  if (_typeFilter != null) {
                    list = list.where((e) => e.type == _typeFilter).toList();
                  }

                  // Apply category filter
                  if (_selectedCategory != 'all') {
                    list = widget.expenseService
                        .filterByCategory(list, _selectedCategory);
                  }

                  // Apply date filter
                  if (_dateFilter != null) {
                    list =
                        widget.expenseService.filterByDate(list, _dateFilter!);
                  }

                  // Apply search query
                  if (_searchQuery.trim().isNotEmpty) {
                    list = widget.expenseService
                        .filterBySearch(list, _searchQuery);
                  }

                  if (list.isEmpty) {
                    return EmptyStateWidget(
                      title: 'No Transactions Found',
                      description:
                          'No expenses match the current filter or search criteria.',
                      actionLabel: 'Add Expense',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddExpenseScreen(
                                expenseService: widget.expenseService),
                          ),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final expense = list[index];
                      return ExpenseCardWidget(
                        expense: expense,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditExpenseScreen(
                                expenseService: widget.expenseService,
                                expense: expense,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, TransactionType? type) {
    final isSelected = _typeFilter == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _typeFilter = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryDark
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? AppConstants.textLight : AppConstants.textDark),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String id) {
    final isSelected = _selectedCategory == id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _selectedCategory = id),
        selectedColor: AppConstants.primaryPurple,
        backgroundColor: Theme.of(context).colorScheme.surface,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? AppConstants.textLight : AppConstants.textDark),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _pickDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFilter ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dateFilter = picked);
    }
  }
}
