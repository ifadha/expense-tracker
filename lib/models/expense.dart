import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { expense, income }

/// Domain model for an expense transaction.
/// Strictly fulfills the schema requirements:
/// - [id]: Unique identifier (Firestore document id)
/// - [title]: Name or merchant of expense
/// - [amount]: Numeric monetary value
/// - [category]: Category name or identifier
/// - [date]: Date and time of expense (Firestore Timestamp compatible)
/// - [note]: Optional descriptive note
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  // Optional extensions for rich UI features
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

  /// Alias for compatibility with existing UI widgets and rules
  String get categoryId => category;

  /// Factory constructor to deserialize from Cloud Firestore DocumentSnapshot
  factory Expense.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Expense document does not exist: ${snapshot.id}');
    }

    DateTime parsedDate;
    final dateVal = data['date'];
    if (dateVal is Timestamp) {
      parsedDate = dateVal.toDate();
    } else if (dateVal is String) {
      parsedDate = DateTime.tryParse(dateVal) ??
          (throw FormatException('Invalid expense date: $dateVal'));
    } else {
      throw const FormatException('Missing or invalid expense date');
    }

    DateTime? parsedCreatedAt;
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(data['createdAt'] as String);
      }
    }

    DateTime? parsedUpdatedAt;
    if (data['updatedAt'] != null) {
      if (data['updatedAt'] is Timestamp) {
        parsedUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
      } else if (data['updatedAt'] is String) {
        parsedUpdatedAt = DateTime.tryParse(data['updatedAt'] as String);
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
      type: (data['type'] == 'income')
          ? TransactionType.income
          : TransactionType.expense,
      recurring: (data['recurring'] as bool?) ?? false,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  /// Serialize to Cloud Firestore Map format using Firestore compatible types & Timestamps
  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'amount': amount,
      'category': category,
      'categoryId':
          category, // Maintained for database schema & security rule compatibility
      // Store formatted date string for clean indexing & range queries
      'date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'timestamp': Timestamp.fromDate(date),
      'wallet': wallet,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      'recurring': recurring,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy of Expense with optional overrides
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? categoryId,
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
      category: category ?? categoryId ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      wallet: wallet ?? this.wallet,
      type: type ?? this.type,
      recurring: recurring ?? this.recurring,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
