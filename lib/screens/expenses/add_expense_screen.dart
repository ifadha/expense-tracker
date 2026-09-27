import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/category.dart';
import '../../services/expense_service.dart';
import '../../services/settings_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/category_selector.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const AddExpenseScreen({
    super.key,
    required this.expenseService,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategoryId = 'subscription';
  DateTime _selectedDate = DateTime.now();
  final String _selectedWallet = 'Spending Wallet';
  TransactionType _type = TransactionType.expense;
  final bool _recurring = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppConstants.primaryPurple,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedAmount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (parsedAmount == null) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.expenseService.addExpense(
        title: _titleController.text.trim(),
        amount: parsedAmount,
        categoryId: _selectedCategoryId,
        date: _selectedDate,
        wallet: _selectedWallet,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        type: _type,
        recurring: _recurring,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully to Firestore'),
            backgroundColor: AppConstants.primaryDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save expense: $e'),
            backgroundColor: AppConstants.expenseRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dateDisplay = DateFormat('dd/MM/yyyy').format(_selectedDate) +
        (isToday ? ' - Today' : '');
    final currency = AppSettingsService.instance.selectedCurrency;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = isDark ? AppConstants.textLight : AppConstants.textDark;
    final secondaryTextColor = isDark
        ? AppConstants.textLight.withValues(alpha: 0.7)
        : AppConstants.textMuted;

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
          'Add Expense',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        centerTitle: false,
        actions: [
          // Expense / Income toggle
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildTypePill('Expense', TransactionType.expense),
                _buildTypePill('Income', TransactionType.income),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Expense Name Field
              Text(
                'Expense Name',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                validator: FormValidators.validateTitle,
                decoration: InputDecoration(
                  hintText: 'e.g. Gym Membership, Spotify',
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Amount Field
              Text(
                'Amount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                validator: FormValidators.validateAmount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '$currency  |  ',
                  prefixStyle: TextStyle(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Add expense amount',
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Category Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select a Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked =
                          await Navigator.pushNamed(context, '/categories');
                      if (picked != null && picked is ExpenseCategory) {
                        setState(() => _selectedCategoryId = picked.id);
                      }
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CategorySelectorWidget(
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (catId) {
                  setState(() => _selectedCategoryId = catId);
                },
                onOpenFullPicker: () async {
                  final picked =
                      await Navigator.pushNamed(context, '/categories');
                  if (picked != null && picked is ExpenseCategory) {
                    setState(() => _selectedCategoryId = picked.id);
                  }
                },
              ),
              const SizedBox(height: 18),

              // 4. Date Picker Field
              Text(
                'Date',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: AppConstants.primaryPurple),
                          const SizedBox(width: 10),
                          Text(
                            dateDisplay,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          color: AppConstants.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 5. Optional Note
              Text(
                'Note (Optional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                validator: FormValidators.validateNote,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add details or memo',
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 28),

              // Primary "Add" Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Expense',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypePill(String title, TransactionType type) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppConstants.textMuted,
          ),
        ),
      ),
    );
  }
}
