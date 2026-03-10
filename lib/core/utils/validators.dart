import 'package:lumbungemas/core/constants/app_constants.dart';

/// Input validators for forms
class Validators {
  Validators._();

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate weight in grams
  static String? weight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }

    if (weight < AppConstants.minWeight) {
      return 'Weight must be at least ${AppConstants.minWeight}g';
    }

    if (weight > AppConstants.maxWeight) {
      return 'Weight cannot exceed ${AppConstants.maxWeight}g';
    }

    return null;
  }

  /// Validate price
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }

    if (price < AppConstants.minPrice) {
      return 'Price must be at least Rp ${AppConstants.minPrice}';
    }

    if (price > AppConstants.maxPrice) {
      return 'Price seems unrealistic';
    }

    return null;
  }

  /// Validate required field
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(
    String? value,
    int max, {
    String fieldName = 'This field',
  }) {
    if (value != null && value.length > max) {
      return '$fieldName cannot exceed $max characters';
    }
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  /// Validate date is not in future
  static String? notFutureDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }

    if (date.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }

    return null;
  }

  /// Validate date range
  static String? dateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Both dates are required';
    }

    if (startDate.isAfter(endDate)) {
      return 'Start date must be before end date';
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  // ============================================
  // SECURITY VALIDATORS - INDONESIAN
  // ============================================

  /// Validate brand name (Indonesian) - prevent injection
  static String? validateBrand(String? value) {
    if (value == null || value.isEmpty) {
      return 'Brand tidak boleh kosong';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 50) {
      return 'Brand harus 2-50 karakter';
    }
    // Only alphanumeric, spaces, hyphens
    if (!RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(trimmed)) {
      return 'Brand hanya boleh huruf, angka, spasi, dan tanda hubung';
    }
    // Check for suspicious patterns
    if (containsSuspiciousPatterns(trimmed)) {
      return 'Format brand tidak valid';
    }
    return null;
  }

  /// Validate quantity (Indonesian) - for gold/silver weight
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah tidak boleh kosong';
    }
    final trimmed = value.trim();
    final quantity = double.tryParse(trimmed);
    if (quantity == null) {
      return 'Jumlah harus berupa angka';
    }
    if (quantity <= 0) {
      return 'Jumlah harus lebih besar dari 0';
    }
    if (quantity > 1000000) {
      return 'Jumlah maksimal 1.000.000 gram';
    }
    return null;
  }

  /// Validate price (Indonesian) - for Rupiah
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga tidak boleh kosong';
    }
    final trimmed = value.trim();
    final price = double.tryParse(trimmed);
    if (price == null) {
      return 'Harga harus berupa angka';
    }
    if (price <= 0) {
      return 'Harga harus lebih besar dari 0';
    }
    if (price > 1000000000) {
      return 'Harga melebihi batas maksimal';
    }
    return null;
  }

  /// Validate date (Indonesian) - ensure date is not in future
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Tanggal tidak boleh kosong';
    }
    if (value.isAfter(DateTime.now())) {
      return 'Tanggal tidak boleh di masa depan';
    }
    // Max 100 years in past
    if (value.isBefore(DateTime.now().subtract(const Duration(days: 36500)))) {
      return 'Tanggal terlalu lama di masa lalu';
    }
    return null;
  }

  /// Check if input contains suspicious patterns (SQL injection, XSS)
  static bool containsSuspiciousPatterns(String input) {
    final lowerInput = input.toLowerCase();
    const suspiciousKeywords = [
      'drop table',
      'insert into',
      'delete from',
      'update ',
      'select ',
      '<script',
      'javascript:',
      'onclick=',
      'onerror=',
      'onload=',
      ';--',
      '/*',
      '*/',
    ];

    for (final keyword in suspiciousKeywords) {
      if (lowerInput.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Sanitize input - basic protection against injection
  static String sanitizeInput(String input) {
    return input
        .replaceAll("'", "''") // Escape single quotes
        .replaceAll('"', '""') // Escape double quotes
        .replaceAll(';', '') // Remove semicolons
        .replaceAll('\n', ' ') // Remove newlines
        .replaceAll('\r', ' ') // Remove carriage returns
        .trim();
  }

  /// Sanitize numeric input - remove non-numeric characters
  static String sanitizeNumeric(String input) {
    return input.replaceAll(RegExp(r'[^0-9.]'), '').trim();
  }

  /// Validate email (Indonesian)
  static String? emailId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }
}
