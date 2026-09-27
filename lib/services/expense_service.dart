import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../utils/constants.dart';

/// Custom domain exception for Expense Firestore operations
class ExpenseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const ExpenseException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'ExpenseException: $message ${code != null ? '($code)' : ''}';
}

/// Dedicated service/repository layer for Firebase Cloud Firestore operations.
/// All Firestore-specific calls, queries, and collection references are isolated here.
class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Internal reference to the Firestore 'expenses' collection
  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection(AppConstants.expensesCollection);

  // ==========================================
  // 1. CREATE EXPENSE
  // ==========================================

  /// Create a new expense document in Firebase Cloud Firestore.
  /// If [expense.id] is empty, Firestore automatically generates a document ID.
  Future<Expense> createExpense(Expense expense) async {
    try {
      final docRef = expense.id.isNotEmpty
          ? _expensesRef.doc(expense.id)
          : _expensesRef.doc();

      final payload = expense.toFirestore();
      payload['createdAt'] = FieldValue.serverTimestamp();

      await docRef.set(payload, SetOptions(merge: true));

      return expense.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw ExpenseException(
        'Failed to create expense: ${e.message ?? e.code}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw ExpenseException(
          'An unexpected error occurred while creating expense.',
          originalError: e);
    }
  }

  /// Convenience helper to create and save an expense with explicit arguments
  Future<Expense> addExpense({
    required String title,
    required double amount,
    required String categoryId,
    required DateTime date,
    String wallet = 'Spending Wallet',
    String? note,
    TransactionType type = TransactionType.expense,
    bool recurring = false,
  }) async {
    final docRef = _expensesRef.doc();
    final expense = Expense(
      id: docRef.id,
      title: title,
      amount: amount,
      category: categoryId,
      date: date,
      wallet: wallet,
      note: note,
      type: type,
      recurring: recurring,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createExpense(expense);
  }

  // ==========================================
  // 2. READ EXPENSES
  // ==========================================

  /// One-time fetch of all expenses from Firestore, ordered descending by date.
  Future<List<Expense>> readExpenses() async {
    try {
      final snapshot =
          await _expensesRef.orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ExpenseException(
        'Failed to fetch expenses: ${e.message ?? e.code}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw ExpenseException('Failed to read expenses from Firestore',
          originalError: e);
    }
  }

  /// Fetch a single expense document by its ID
  Future<Expense?> readExpenseById(String id) async {
    try {
      final docSnap = await _expensesRef.doc(id).get();
      if (!docSnap.exists) return null;
      return Expense.fromFirestore(docSnap);
    } on FirebaseException catch (e) {
      throw ExpenseException(
        'Failed to fetch expense details: ${e.message ?? e.code}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Real-time stream of all expenses, sorted descending by date.
  Stream<List<Expense>> readExpensesStream() {
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    });
  }

  /// Alias for backward compatibility with existing screen stream listeners
  Stream<List<Expense>> watchAllExpenses() => readExpensesStream();

  // ==========================================
  // 3. UPDATE EXPENSE
  // ==========================================

  /// Update an existing expense in Cloud Firestore.
  Future<void> updateExpense(Expense expense) async {
    if (expense.id.isEmpty) {
      throw const ExpenseException(
          'Cannot update an expense with an empty ID.');
    }

    try {
      final docRef = _expensesRef.doc(expense.id);
      final payload = expense.toFirestore();
      payload['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(payload, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ExpenseException(
        'Failed to update expense: ${e.message ?? e.code}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw ExpenseException(
          'An unexpected error occurred while updating expense.',
          originalError: e);
    }
  }

  // ==========================================
  // 4. DELETE EXPENSE
  // ==========================================

  /// Delete an expense document from Cloud Firestore.
  Future<void> deleteExpense(String expenseId) async {
    if (expenseId.isEmpty) {
      throw const ExpenseException(
          'Cannot delete an expense with an empty ID.');
    }

    try {
      await _expensesRef.doc(expenseId).delete();
    } on FirebaseException catch (e) {
      throw ExpenseException(
        'Failed to delete expense: ${e.message ?? e.code}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw ExpenseException(
          'An unexpected error occurred while deleting expense.',
          originalError: e);
    }
  }

  // ==========================================
  // 5. FILTER BY CATEGORY
  // ==========================================

  /// In-memory filter of an expense list by category
  List<Expense> filterByCategory(List<Expense> expenses, String? category) {
    if (category == null || category.trim().isEmpty || category == 'all') {
      return expenses;
    }
    return expenses
        .where((e) => e.category == category || e.categoryId == category)
        .toList();
  }

  /// Cloud Firestore query to fetch expenses for a specific category
  Future<List<Expense>> readExpensesByCategory(String category) async {
    try {
      final snapshot = await _expensesRef
          .where('categoryId', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ExpenseException(
          'Failed to filter expenses by category: ${e.message}',
          code: e.code);
    }
  }

  /// Real-time stream of expenses for a specific category
  Stream<List<Expense>> watchExpensesByCategory(String category) {
    return _expensesRef
        .where('categoryId', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Expense.fromFirestore(d)).toList());
  }

  // ==========================================
  // 6. FILTER BY DATE
  // ==========================================

  /// In-memory filter of an expense list for an exact calendar date
  List<Expense> filterByDate(List<Expense> expenses, DateTime date) {
    return expenses.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList();
  }

  /// In-memory filter of an expense list for a date range (inclusive)
  List<Expense> filterByDateRange(
      List<Expense> expenses, DateTime start, DateTime end) {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return expenses.where((e) {
      return e.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Query Firestore for expenses on an exact date (YYYY-MM-DD)
  Future<List<Expense>> readExpensesByDate(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      final snapshot =
          await _expensesRef.where('date', isEqualTo: dateStr).get();
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ExpenseException('Failed to filter expenses by date: ${e.message}',
          code: e.code);
    }
  }

  /// Real-time stream of expenses for a specific month (e.g. YYYY-MM)
  Stream<List<Expense>> watchExpensesForMonth(int year, int month) {
    final monthStr = month.toString().padLeft(2, '0');
    final monthPrefix = '$year-$monthStr';

    return _expensesRef
        .where('date', isGreaterThanOrEqualTo: '$monthPrefix-01')
        .where('date', isLessThanOrEqualTo: '$monthPrefix-31')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    });
  }

  /// Search query filter across title, note, and amount
  List<Expense> filterBySearch(List<Expense> expenses, String query) {
    if (query.trim().isEmpty) return expenses;
    final lower = query.toLowerCase();
    return expenses.where((e) {
      final matchesTitle = e.title.toLowerCase().contains(lower);
      final matchesNote = e.note?.toLowerCase().contains(lower) ?? false;
      final matchesAmount = e.amount.toString().contains(lower);
      final matchesCat = e.category.toLowerCase().contains(lower);
      return matchesTitle || matchesNote || matchesAmount || matchesCat;
    }).toList();
  }

  /// Calculate total sum for an expense list with optional transaction type
  double calculateMonthTotal(List<Expense> expenses,
      {TransactionType type = TransactionType.expense}) {
    return expenses
        .where((e) => e.type == type)
        .fold(0.0, (runningTotal, item) => runningTotal + item.amount);
  }
}
