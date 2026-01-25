/// Form validation utilities.
///
/// Provides common validators for form fields. All validators return
/// null if valid, or an error message string if invalid.
class ValidationUtils {
  ValidationUtils._();

  /// Validate that a field is not empty.
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate email format.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate password strength.
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  /// Validate password confirmation matches.
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate phone number format.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    // Remove common formatting characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check for valid phone format (international or local)
    final phoneRegex = RegExp(r'^\+?[\d]{10,15}$');

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate a positive number.
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for optional fields
    }

    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '${fieldName ?? 'Value'} must be a positive number';
    }

    return null;
  }

  /// Validate weight input.
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Weight is optional
    }

    final weight = double.tryParse(value);
    if (weight == null || weight <= 0 || weight > 1500) {
      return 'Please enter a valid weight (1-1500)';
    }

    return null;
  }

  /// Validate reps input.
  static String? validateReps(String? value) {
    if (value == null || value.isEmpty) {
      return 'Reps is required';
    }

    final reps = int.tryParse(value);
    if (reps == null || reps <= 0 || reps > 1000) {
      return 'Please enter valid reps (1-1000)';
    }

    return null;
  }

  /// Validate sets input.
  static String? validateSets(String? value) {
    if (value == null || value.isEmpty) {
      return 'Sets is required';
    }

    final sets = int.tryParse(value);
    if (sets == null || sets <= 0 || sets > 100) {
      return 'Please enter valid sets (1-100)';
    }

    return null;
  }

  /// Validate duration in minutes.
  static String? validateDuration(String? value, {int maxMinutes = 480}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final duration = int.tryParse(value);
    if (duration == null || duration <= 0 || duration > maxMinutes) {
      return 'Please enter valid duration (1-$maxMinutes minutes)';
    }

    return null;
  }

  /// Validate a name (letters, spaces, hyphens, apostrophes).
  static String? validateName(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Name'} is required';
    }

    if (value.trim().length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters';
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Please enter a valid ${fieldName?.toLowerCase() ?? 'name'}';
    }

    return null;
  }

  /// Validate minimum length.
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length.
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be at most $maxLength characters';
    }

    return null;
  }

  /// Validate URL format.
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validate age (must be between min and max).
  static String? validateAge(String? value, {int min = 13, int max = 120}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final age = int.tryParse(value);
    if (age == null || age < min || age > max) {
      return 'Please enter a valid age ($min-$max)';
    }

    return null;
  }

  /// Validate height in cm.
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final height = double.tryParse(value);
    if (height == null || height < 50 || height > 300) {
      return 'Please enter a valid height (50-300 cm)';
    }

    return null;
  }

  /// Chain multiple validators together.
  ///
  /// Returns the first error found, or null if all pass.
  static String? validateMultiple(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Create a required validator with custom field name.
  static String? Function(String?) required(String fieldName) {
    return (value) => validateRequired(value, fieldName: fieldName);
  }

  /// Create a min length validator with custom field name.
  static String? Function(String?) minLength(int length, {String? fieldName}) {
    return (value) => validateMinLength(value, length, fieldName: fieldName);
  }

  /// Create a max length validator with custom field name.
  static String? Function(String?) maxLength(int length, {String? fieldName}) {
    return (value) => validateMaxLength(value, length, fieldName: fieldName);
  }
}
