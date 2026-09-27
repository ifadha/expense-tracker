import 'package:flutter/material.dart';
import '../../services/expense_service.dart';
import '../../services/settings_service.dart';
import '../../utils/constants.dart';

class AccountScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const AccountScreen({
    super.key,
    required this.expenseService,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AppSettingsService _settings = AppSettingsService.instance;
  late final TextEditingController _budgetController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _budgetController =
        TextEditingController(text: _settings.monthlyBudget.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final rawValue = _budgetController.text.trim();
    if (rawValue.isEmpty) {
      _showBudgetError('Please enter a valid monthly budget.');
      return;
    }

    final parsed = double.tryParse(rawValue);
    if (parsed == null || parsed <= 0) {
      _showBudgetError('Budget must be greater than zero.');
      return;
    }

    await _settings.setMonthlyBudget(parsed);
    setState(() => _isSaved = true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Target budget updated successfully'),
        backgroundColor: AppConstants.primaryDark,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isSaved = false);
    });
  }

  void _showBudgetError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.expenseRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCurrency = _settings.selectedCurrency;
    const currencySymbols = AppConstants.currencyOptions;
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
            stops: const [0.0, 0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Account & Settings',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppConstants.textLight
                          : AppConstants.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A2333)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: isDark ? const Color(0xFF2B374B) : Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E143C)
                          .withValues(alpha: isDark ? 0.18 : 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppConstants.primaryPurple,
                            Color(0xFFA855F7)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryPurple
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'IF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ifadha',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppConstants.textLight
                                  : AppConstants.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppConstants.cardDark
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Display Currency',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppConstants.textLight
                            : AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currencySymbols.map((c) {
                        final isSelected = c['symbol'] == selectedCurrency;
                        return ChoiceChip(
                          label: Text(c['name']!),
                          selected: isSelected,
                          onSelected: (selected) async {
                            if (selected) {
                              await _settings.setSelectedCurrency(c['symbol']!);
                              if (mounted) setState(() {});
                            }
                          },
                          selectedColor: AppConstants.primaryDark,
                          backgroundColor: isDark
                              ? const Color(0xFF1F2A3A)
                              : const Color(0xFFF1EFF9),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppConstants.textLight
                                    : AppConstants.textDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppConstants.cardDark
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Target Budget',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppConstants.textLight
                            : AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Used to calculate progress bars and spending velocity warnings.',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppConstants.textLight.withValues(alpha: 0.7)
                              : AppConstants.textMuted),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              prefixText: '$selectedCurrency ',
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF101827)
                                  : const Color(0xFFF8F7FC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _saveBudget,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(_isSaved ? 'Saved!' : 'Save',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Lumina Expense Tracker v2.4 · Flutter Material 3',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppConstants.textLight.withValues(alpha: 0.7)
                        : AppConstants.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
