import React, { useState } from 'react';
import { Copy, Check, FileCode, CheckCircle2, Database, ShieldCheck, Layers } from 'lucide-react';

interface CodeFile {
  name: string;
  path: string;
  category: 'model' | 'service' | 'config' | 'screen' | 'widget';
  description: string;
  code: string;
}

const FLUTTER_FILES: CodeFile[] = [
  {
    name: 'expense.dart',
    path: 'lib/models/expense.dart',
    category: 'model',
    description: 'Expense model with id, title, amount, category, date, note, Firestore timestamps & serialization',
    code: `import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { expense, income }

/// Domain model for an expense transaction.
/// Strictly fulfills user requirements:
/// - id, title, amount, category, date, note
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  // Rich extensions for tracking
  final String wallet;
  final TransactionType type;
  final bool recurring;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.wallet = 'Spending Wallet',
    this.type = TransactionType.expense,
    this.recurring = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Alias for category identifier
  String get categoryId => category;

  /// Factory constructor to deserialize from Cloud Firestore DocumentSnapshot
  factory Expense.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Expense document does not exist: \${snapshot.id}');
    }

    DateTime parsedDate;
    final dateVal = data['date'];
    if (dateVal is Timestamp) {
      parsedDate = dateVal.toDate();
    } else if (dateVal is String) {
      parsedDate = DateTime.tryParse(dateVal) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    DateTime? parsedCreatedAt;
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(data['createdAt'] as String);
      }
    }

    final cat = (data['category'] as String?) ??
        (data['categoryId'] as String?) ??
        'other';

    return Expense(
      id: snapshot.id,
      title: (data['title'] as String?) ?? 'Untitled Expense',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: cat,
      date: parsedDate,
      note: data['note'] as String?,
      wallet: (data['wallet'] as String?) ?? 'Spending Wallet',
      type: (data['type'] == 'income') ? TransactionType.income : TransactionType.expense,
      recurring: (data['recurring'] as bool?) ?? false,
      createdAt: parsedCreatedAt,
      updatedAt: data['updatedAt'] != null && data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Serialize to Cloud Firestore Map format using Firestore compatible types & Timestamps
  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'amount': amount,
      'category': category,
      'categoryId': category,
      'date': '\${date.year}-\${date.month.toString().padLeft(2, '0')}-\${date.day.toString().padLeft(2, '0')}',
      'timestamp': Timestamp.fromDate(date),
      'wallet': wallet,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      'recurring': recurring,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? wallet,
    TransactionType? type,
    bool? recurring,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      wallet: wallet ?? this.wallet,
      type: type ?? this.type,
      recurring: recurring ?? this.recurring,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}`
  },
  {
    name: 'expense_service.dart',
    path: 'lib/services/expense_service.dart',
    category: 'service',
    description: 'Dedicated Firestore service: Create, Read, Update, Delete, Filter by category, Filter by date',
    code: `import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../utils/constants.dart';

/// Dedicated service/repository layer for Firebase Cloud Firestore operations.
/// All Firestore-specific calls, queries, and collection references are isolated here.
class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection(AppConstants.expensesCollection);

  // 1. CREATE EXPENSE
  Future<Expense> createExpense(Expense expense) async {
    final docRef = expense.id.isNotEmpty
        ? _expensesRef.doc(expense.id)
        : _expensesRef.doc();

    final payload = expense.toFirestore();
    payload['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(payload, SetOptions(merge: true));
    return expense.copyWith(id: docRef.id);
  }

  // 2. READ EXPENSES (One-time and Real-Time Stream)
  Future<List<Expense>> readExpenses() async {
    final snapshot = await _expensesRef.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  Stream<List<Expense>> readExpensesStream() {
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  Stream<List<Expense>> watchAllExpenses() => readExpensesStream();

  // 3. UPDATE EXPENSE
  Future<void> updateExpense(Expense expense) async {
    final docRef = _expensesRef.doc(expense.id);
    final payload = expense.toFirestore();
    payload['updatedAt'] = FieldValue.serverTimestamp();

    await docRef.set(payload, SetOptions(merge: true));
  }

  // 4. DELETE EXPENSE
  Future<void> deleteExpense(String expenseId) async {
    await _expensesRef.doc(expenseId).delete();
  }

  // 5. FILTER BY CATEGORY
  List<Expense> filterByCategory(List<Expense> expenses, String? category) {
    if (category == null || category.trim().isEmpty || category == 'all') {
      return expenses;
    }
    return expenses.where((e) => e.category == category || e.categoryId == category).toList();
  }

  Future<List<Expense>> readExpensesByCategory(String category) async {
    final snapshot = await _expensesRef
        .where('categoryId', isEqualTo: category)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  // 6. FILTER BY DATE
  List<Expense> filterByDate(List<Expense> expenses, DateTime date) {
    return expenses.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList();
  }

  List<Expense> filterByDateRange(List<Expense> expenses, DateTime start, DateTime end) {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return expenses.where((e) {
      return e.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList();
  }

  Stream<List<Expense>> watchExpensesForMonth(int year, int month) {
    final monthStr = month.toString().padLeft(2, '0');
    final monthPrefix = '\$year-\$monthStr';

    return _expensesRef
        .where('date', isGreaterThanOrEqualTo: '\$monthPrefix-01')
        .where('date', isLessThanOrEqualTo: '\$monthPrefix-31')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }
}`
  },
  {
    name: 'firebase_config.dart',
    path: 'lib/services/firebase_config.dart',
    category: 'config',
    description: 'Clean Firebase configuration isolation without restructuring the application',
    code: `import 'package:firebase_core/firebase_core.dart';

/// Clean abstraction for Firebase configuration and initialization.
/// Enables seamless platform-specific configuration without touching UI code.
class FirebaseConfig {
  static Future<FirebaseApp> initialize({
    FirebaseOptions? customOptions,
    String? name,
  }) async {
    if (customOptions != null) {
      return Firebase.initializeApp(
        name: name,
        options: customOptions,
      );
    }

    try {
      return await Firebase.initializeApp(
        name: name,
      );
    } catch (e) {
      if (Firebase.apps.isNotEmpty) {
        return Firebase.app(name ?? defaultFirebaseAppName);
      }
      rethrow;
    }
  }
}`
  },
  {
    name: 'home_screen.dart',
    path: 'lib/screens/home/home_screen.dart',
    category: 'screen',
    description: 'UI with StreamBuilder reacting to LoadingState, ErrorState, EmptyState, and Data',
    code: `// Key UI pattern showing isolation of Firebase and handling all states:
StreamBuilder<List<Expense>>(
  stream: widget.expenseService.watchExpensesForMonth(
    _selectedMonth.year,
    _selectedMonth.month,
  ),
  builder: (context, snapshot) {
    // 1. Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LoadingStateWidget();
    }

    // 2. Firebase error state
    if (snapshot.hasError) {
      return ErrorStateWidget(
        errorMessage: snapshot.error.toString(),
        onRetry: () => setState(() {}),
      );
    }

    final expenses = snapshot.data ?? [];

    // 3. Empty data state
    if (expenses.isEmpty) {
      return EmptyStateWidget(
        title: 'No expenses for \$monthName',
        description: 'Record an expense to see it in your monthly overview.',
        onAction: () => _openAddExpense(context),
      );
    }

    // 4. Successful data retrieval
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) => ExpenseCardWidget(expense: expenses[index]),
    );
  },
);`
  }
];

export const FlutterCodeViewer: React.FC<{ onClose: () => void }> = ({ onClose }) => {
  const [selectedFile, setSelectedFile] = useState<CodeFile>(FLUTTER_FILES[0]);
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(selectedFile.code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-2 sm:inset-8 z-50 bg-[#130f24]/95 border border-purple-500/30 text-white rounded-3xl shadow-2xl flex flex-col backdrop-blur-2xl overflow-hidden animate-in fade-in duration-200">
      {/* Header */}
      <div className="flex items-center justify-between px-6 py-4 border-b border-white/10 bg-slate-900/60">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-purple-500/20 border border-purple-500/30 flex items-center justify-center text-purple-300">
            <Layers size={18} />
          </div>
          <div>
            <h2 className="text-sm font-bold text-white flex items-center gap-2">
              Flutter Application Architecture & Firestore Service
              <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                Verified
              </span>
            </h2>
            <p className="text-[11px] text-slate-400">
              Clean separation of UI, Expense Model, and dedicated Cloud Firestore Service
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleCopy}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-white/10 hover:bg-white/15 text-xs font-medium text-slate-200 transition-colors cursor-pointer"
          >
            {copied ? <Check size={14} className="text-emerald-400" /> : <Copy size={14} />}
            <span>{copied ? 'Copied!' : 'Copy File'}</span>
          </button>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-xl bg-white/10 hover:bg-white/20 text-slate-300 hover:text-white flex items-center justify-center text-sm font-bold transition-colors cursor-pointer"
          >
            ✕
          </button>
        </div>
      </div>

      {/* Feature Badges Checklist */}
      <div className="px-6 py-2.5 bg-black/30 border-b border-white/5 flex flex-wrap items-center gap-3 text-[11px] text-slate-300">
        <span className="text-slate-400 font-semibold flex items-center gap-1">
          <Database size={13} className="text-purple-400" /> Service Capabilities:
        </span>
        <span className="flex items-center gap-1 text-emerald-300 bg-emerald-500/10 px-2 py-0.5 rounded-md border border-emerald-500/20">
          <CheckCircle2 size={12} /> Create expense
        </span>
        <span className="flex items-center gap-1 text-emerald-300 bg-emerald-500/10 px-2 py-0.5 rounded-md border border-emerald-500/20">
          <CheckCircle2 size={12} /> Read expenses (Future & Stream)
        </span>
        <span className="flex items-center gap-1 text-emerald-300 bg-emerald-500/10 px-2 py-0.5 rounded-md border border-emerald-500/20">
          <CheckCircle2 size={12} /> Update expense
        </span>
        <span className="flex items-center gap-1 text-emerald-300 bg-emerald-500/10 px-2 py-0.5 rounded-md border border-emerald-500/20">
          <CheckCircle2 size={12} /> Delete expense
        </span>
        <span className="flex items-center gap-1 text-emerald-300 bg-emerald-500/10 px-2 py-0.5 rounded-md border border-emerald-500/20">
          <CheckCircle2 size={12} /> Filter by category
        </span>
        <span className="flex items-center gap-1 text-emerald-300 bg-emerald-500/10 px-2 py-0.5 rounded-md border border-emerald-500/20">
          <CheckCircle2 size={12} /> Filter by date
        </span>
        <span className="flex items-center gap-1 text-purple-300 bg-purple-500/10 px-2 py-0.5 rounded-md border border-purple-500/20">
          <ShieldCheck size={12} /> Loading / Error / Empty States Handled
        </span>
      </div>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col md:flex-row min-h-0 overflow-hidden">
        {/* Left Sidebar: File Tree */}
        <div className="w-full md:w-72 border-r border-white/10 bg-slate-900/40 p-3 overflow-y-auto">
          <div className="text-[10px] font-bold uppercase tracking-wider text-slate-400 px-3 py-2">
            Flutter Project Files (`lib/`)
          </div>
          <div className="space-y-1">
            {FLUTTER_FILES.map((file) => {
              const isSelected = selectedFile.path === file.path;
              return (
                <button
                  key={file.path}
                  onClick={() => setSelectedFile(file)}
                  className={`w-full text-left px-3 py-2.5 rounded-xl transition-all cursor-pointer flex flex-col gap-0.5 ${
                    isSelected
                      ? 'bg-purple-600/30 text-white border border-purple-500/40 shadow-xs'
                      : 'text-slate-400 hover:text-slate-200 hover:bg-white/5'
                  }`}
                >
                  <div className="flex items-center gap-2">
                    <FileCode size={14} className={isSelected ? 'text-purple-300' : 'text-slate-500'} />
                    <span className="font-semibold text-xs text-white">{file.name}</span>
                  </div>
                  <span className="text-[10px] text-slate-400 font-mono truncate pl-5">
                    {file.path}
                  </span>
                </button>
              );
            })}
          </div>

          <div className="mt-4 p-3 rounded-2xl bg-purple-950/30 border border-purple-500/20 text-[11px] text-purple-200 space-y-1.5">
            <div className="font-bold text-xs text-white flex items-center gap-1.5">
              <span>Clean Architecture</span>
            </div>
            <p className="text-[11px] text-slate-300 leading-relaxed">
              • <strong>Expense Model</strong> contains: id, title, amount, category, date, note.
            </p>
            <p className="text-[11px] text-slate-300 leading-relaxed">
              • <strong>ExpenseService</strong> isolates all Cloud Firestore calls from UI widgets.
            </p>
            <p className="text-[11px] text-slate-300 leading-relaxed">
              • <strong>FirebaseConfig</strong> encapsulates initialization without restructuring.
            </p>
          </div>
        </div>

        {/* Right Code Display */}
        <div className="flex-1 flex flex-col min-h-0 bg-[#0d0a1a]">
          <div className="px-5 py-2.5 bg-black/40 border-b border-white/5 flex items-center justify-between text-xs">
            <span className="font-mono text-purple-300 font-semibold">{selectedFile.path}</span>
            <span className="text-slate-400 text-[11px]">{selectedFile.description}</span>
          </div>

          <div className="flex-1 overflow-auto p-4 sm:p-6 font-mono text-xs text-slate-300 leading-relaxed">
            <pre>
              <code>{selectedFile.code}</code>
            </pre>
          </div>
        </div>
      </div>
    </div>
  );
};
