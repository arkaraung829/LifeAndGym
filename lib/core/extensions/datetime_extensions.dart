/// Extension methods on DateTime for common operations.
extension DateTimeExtensions on DateTime {
  /// Check if this date is the same day as another date.
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if this date is today.
  bool get isToday => isSameDay(DateTime.now());

  /// Check if this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  /// Check if this date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }

  /// Check if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Check if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Check if this date is within the current week.
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if this date is within the current month.
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if this date is within the current year.
  bool get isThisYear => year == DateTime.now().year;

  /// Get the start of the day (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get the end of the day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get the start of the week (Monday).
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  /// Get the end of the week (Sunday).
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).endOfDay;
  }

  /// Get the start of the month.
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get the end of the month.
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Get the number of days in this month.
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Get the age in years from this date.
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Add a number of days.
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract a number of days.
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Add a number of weeks.
  DateTime addWeeks(int weeks) => add(Duration(days: weeks * 7));

  /// Add a number of months.
  DateTime addMonths(int months) {
    int newMonth = month + months;
    int newYear = year;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    // Handle day overflow (e.g., Jan 31 + 1 month = Feb 28/29)
    final daysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = day > daysInNewMonth ? daysInNewMonth : day;

    return DateTime(newYear, newMonth, newDay, hour, minute, second);
  }

  /// Get a human-readable relative time string.
  String toRelativeString() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      // Future
      final absDiff = difference.abs();
      if (absDiff.inDays > 0) {
        return 'in ${absDiff.inDays} day${absDiff.inDays == 1 ? '' : 's'}';
      }
      if (absDiff.inHours > 0) {
        return 'in ${absDiff.inHours} hour${absDiff.inHours == 1 ? '' : 's'}';
      }
      if (absDiff.inMinutes > 0) {
        return 'in ${absDiff.inMinutes} min';
      }
      return 'in a moment';
    }

    // Past
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
    if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    }
    if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months month${months == 1 ? '' : 's'} ago';
    }
    final years = difference.inDays ~/ 365;
    return '$years year${years == 1 ? '' : 's'} ago';
  }

  /// Get day name (Monday, Tuesday, etc.).
  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  /// Get short day name (Mon, Tue, etc.).
  String get shortDayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Get month name (January, February, etc.).
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Get short month name (Jan, Feb, etc.).
  String get shortMonthName {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
