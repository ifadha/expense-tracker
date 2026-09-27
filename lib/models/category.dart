class ExpenseCategory {
  final String id;
  final String name;
  final String iconName;
  final int colorValue;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorValue': colorValue,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as String? ?? 'other',
      name: map['name'] as String? ?? 'Other',
      iconName: map['iconName'] as String? ?? 'grid',
      colorValue: map['colorValue'] as int? ?? 0xFF704FE6,
    );
  }
}
