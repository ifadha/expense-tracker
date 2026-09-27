import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/category_selector.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseService expenseService;
  final Expense expense;

  const EditExpenseScreen({
    Key? key,
    required this.expenseService,
    required this.expense,
  }) : super(key: key);

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedCategoryId;
  late DateTime _selectedDate;
  late TransactionType _type;
  late String _selectedWallet;
  late bool _recurring;

  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
    _noteController = TextEditingController(text: widget.expense.note ?? '');
    _selectedCategoryId = widget.expense.categoryId;
    _selectedDate = widget.expense.date;
    _type = widget.expense.type;
    _selectedWallet = widget.expense.wallet;
    _recurring = widget.expense.recurring;
  }

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
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final parsed = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (parsed == null) return;

    setState(() => _isSaving = true);
    try {
      final updated = widget.expense.copyWith(
        title: _titleController.text.trim(),
        amount: parsed,
        categoryId: _selectedCategoryId,
        date: _selectedDate,
        wallet: _selectedWallet,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        type: _type,
        recurring: _recurring,
      );

      await widget.expenseService.updateExpense(updated);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense updated in Firestore'),
            backgroundColor: AppConstants.primaryDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: AppConstants.expenseRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Expense?'),
        content: const Text('Are you sure you want to permanently delete this expense from Cloud Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.expenseRed),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      try {
        await widget.expenseService.deleteExpense(widget.expense.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted from Firestore')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppConstants.expenseRed),
          );
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Expense',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppConstants.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline, color: AppConstants.expenseRed),
            onPressed: _isDeleting ? null : _confirmDelete,
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
              const Text(
                'Expense Title',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.textMuted),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                validator: FormValidators.validateTitle,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Amount',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.textMuted),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                validator: FormValidators.validateAmount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '\$  |  ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Category',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.textMuted),
              ),
              const SizedBox(height: 8),
              CategorySelectorWidget(
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (cat) => setState(() => _selectedCategoryId = cat),
              ),
              const SizedBox(height: 18),
              const Text(
                'Date',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.textMuted),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppConstants.primaryPurple),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Note',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.textMuted),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                validator: FormValidators.validateNote,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Expense', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
