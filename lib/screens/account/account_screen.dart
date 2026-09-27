import 'package:flutter/material.dart';
import '../../services/expense_service.dart';
import '../../utils/constants.dart';

class AccountScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const AccountScreen({
    Key? key,
    required this.expenseService,
  }) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _selectedCurrency = '\$';
  final _budgetController = TextEditingController(text: '3200');
  bool _isSaved = false;

  final List<Map<String, String>> _currencies = [
    {'symbol': '\$', 'name': 'USD (\$)'},
    {'symbol': '€', 'name': 'EUR (€)'},
    {'symbol': '£', 'name': 'GBP (£)'},
    {'symbol': '¥', 'name': 'JPY (¥)'},
    {'symbol': '₹', 'name': 'INR (₹)'},
    {'symbol': 'C\$', 'name': 'CAD (C\$)'},
  ];

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    setState(() => _isSaved = true);
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            physics: const BouncingScrollPhysics(),
            children: [
              // Header Title
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Account & Settings',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E143C).withOpacity(0.04),
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
                          colors: [AppConstants.primaryPurple, Color(0xFFA855F7)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'AM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alex Morgan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppConstants.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'alex.morgan@lumina.io',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.textMuted,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pro Plan Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Currency Picker Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Display Currency',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currencies.map((c) {
                        final isSelected = c['symbol'] == _selectedCurrency;
                        return ChoiceChip(
                          label: Text(c['name']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCurrency = c['symbol']!);
                            }
                          },
                          selectedColor: AppConstants.primaryDark,
                          backgroundColor: const Color(0xFFF1EFF9),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppConstants.textDark,
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

              // Monthly Target Budget
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Target Budget',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Used to calculate progress bars and spending velocity warnings.',
                      style: TextStyle(fontSize: 11, color: AppConstants.textMuted),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixText: '$_selectedCurrency ',
                              filled: true,
                              fillColor: const Color(0xFFF8F7FC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _saveBudget,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(_isSaved ? 'Saved!' : 'Save', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Connected Wallets
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connected Wallets',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildWalletRow(
                      name: 'Spending Wallet',
                      type: 'Active Checking',
                      balance: '\$5,631.22',
                      color: AppConstants.primaryPurple,
                      icon: Icons.account_balance_wallet,
                    ),
                    const Divider(height: 16),
                    _buildWalletRow(
                      name: 'MasterCard Black',
                      type: '•••• 9918 (Credit)',
                      balance: '\$1,240.00',
                      color: const Color(0xFFEB001B),
                      icon: Icons.credit_card,
                    ),
                    const Divider(height: 16),
                    _buildWalletRow(
                      name: 'High-Yield Savings',
                      type: 'Reserve vault',
                      balance: '\$14,850.50',
                      color: const Color(0xFF10B981),
                      icon: Icons.savings,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Version
              const Center(
                child: Text(
                  'Lumina Expense Tracker v2.4 · Flutter Material 3',
                  style: TextStyle(fontSize: 11, color: AppConstants.textMuted),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletRow({
    required String name,
    required String type,
    required String balance,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textDark,
                ),
              ),
              Text(
                type,
                style: const TextStyle(fontSize: 11, color: AppConstants.textMuted),
              ),
            ],
          ),
        ),
        Text(
          balance,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppConstants.textDark,
          ),
        ),
      ],
    );
  }
}
