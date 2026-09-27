class FormValidators {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expense title is required';
    }
    if (value.trim().length > 120) {
      return 'Title cannot exceed 120 characters';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Please enter a valid numeric amount';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than 0';
    }
    if (parsed > 10000000) {
      return 'Amount exceeds maximum limit';
    }
    return null;
  }

  static String? validateCategory(String? categoryId) {
    if (categoryId == null || categoryId.trim().isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Please select a date';
    }
    return null;
  }

  static String? validateNote(String? value) {
    if (value != null && value.length > 300) {
      return 'Note cannot exceed 300 characters';
    }
    return null;
  }
}
