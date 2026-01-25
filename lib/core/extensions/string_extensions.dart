/// Extension methods on String for common operations.
extension StringExtensions on String {
  /// Capitalize the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize the first letter of each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Convert to camelCase.
  String get camelCase {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;

    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalize).join('');
  }

  /// Convert to snake_case.
  String get snakeCase {
    if (isEmpty) return this;
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'^_'), '').replaceAll(RegExp(r'[\s-]+'), '_').toLowerCase();
  }

  /// Check if string is a valid email.
  bool get isValidEmail {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this);
  }

  /// Check if string is a valid phone number.
  bool get isValidPhone {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final regex = RegExp(r'^\+?[\d]{10,15}$');
    return regex.hasMatch(cleaned);
  }

  /// Check if string is a valid URL.
  bool get isValidUrl {
    final regex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return regex.hasMatch(this);
  }

  /// Check if string contains only numbers.
  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(this) != null;
  }

  /// Check if string contains only letters.
  bool get isAlpha {
    if (isEmpty) return false;
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Check if string contains only letters and numbers.
  bool get isAlphanumeric {
    if (isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Truncate string to a maximum length with ellipsis.
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Remove all whitespace.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Remove extra whitespace (multiple spaces become single space).
  String get normalizeWhitespace => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Get initials (first letter of each word, max 2).
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words.first.isNotEmpty ? words.first[0].toUpperCase() : '';
    }
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  /// Convert to int, or return null if invalid.
  int? toIntOrNull() => int.tryParse(this);

  /// Convert to double, or return null if invalid.
  double? toDoubleOrNull() => double.tryParse(this);

  /// Reverse the string.
  String get reversed => split('').reversed.join('');

  /// Check if string is null or empty.
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not null and not empty.
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Mask part of the string (for privacy, e.g., email, phone).
  String mask({int visibleStart = 3, int visibleEnd = 3, String maskChar = '*'}) {
    if (length <= visibleStart + visibleEnd) return this;

    final start = substring(0, visibleStart);
    final end = substring(length - visibleEnd);
    final masked = maskChar * (length - visibleStart - visibleEnd);

    return '$start$masked$end';
  }

  /// Mask email (show first 2 chars and domain).
  String get maskedEmail {
    final parts = split('@');
    if (parts.length != 2) return this;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) return this;

    return '${name.substring(0, 2)}${'*' * (name.length - 2)}@$domain';
  }

  /// Format as phone number (basic US format).
  String get formattedPhone {
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    return this;
  }
}

/// Extension on nullable String.
extension NullableStringExtensions on String? {
  /// Check if string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Return the string or a default value if null/empty.
  String orDefault(String defaultValue) {
    return isNullOrEmpty ? defaultValue : this!;
  }
}
