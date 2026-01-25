import 'package:intl/intl.dart';

/// Utility class for formatting data for display.
class Formatters {
  Formatters._();

  // Date formatters
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');
  static final _timeFormat = DateFormat('h:mm a');
  static final _dayMonthFormat = DateFormat('MMM d');
  static final _weekdayFormat = DateFormat('EEEE');
  static final _shortWeekdayFormat = DateFormat('EEE');
  static final _monthYearFormat = DateFormat('MMMM yyyy');

  /// Format a date (e.g., "Jan 15, 2026").
  static String date(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  /// Format a date with time (e.g., "Jan 15, 2026 3:30 PM").
  static String dateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateTimeFormat.format(dateTime);
  }

  /// Format time only (e.g., "3:30 PM").
  static String time(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _timeFormat.format(dateTime);
  }

  /// Format day and month (e.g., "Jan 15").
  static String dayMonth(DateTime? date) {
    if (date == null) return '';
    return _dayMonthFormat.format(date);
  }

  /// Format weekday (e.g., "Monday").
  static String weekday(DateTime? date) {
    if (date == null) return '';
    return _weekdayFormat.format(date);
  }

  /// Format short weekday (e.g., "Mon").
  static String shortWeekday(DateTime? date) {
    if (date == null) return '';
    return _shortWeekdayFormat.format(date);
  }

  /// Format month and year (e.g., "January 2026").
  static String monthYear(DateTime? date) {
    if (date == null) return '';
    return _monthYearFormat.format(date);
  }

  /// Format relative time (e.g., "2 hours ago", "in 3 days").
  static String relativeTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final isPast = difference.isNegative == false;

    final absDiff = difference.abs();

    String timeStr;
    if (absDiff.inDays > 365) {
      final years = (absDiff.inDays / 365).floor();
      timeStr = years == 1 ? '1 year' : '$years years';
    } else if (absDiff.inDays > 30) {
      final months = (absDiff.inDays / 30).floor();
      timeStr = months == 1 ? '1 month' : '$months months';
    } else if (absDiff.inDays > 0) {
      timeStr = absDiff.inDays == 1 ? '1 day' : '${absDiff.inDays} days';
    } else if (absDiff.inHours > 0) {
      timeStr = absDiff.inHours == 1 ? '1 hour' : '${absDiff.inHours} hours';
    } else if (absDiff.inMinutes > 0) {
      timeStr = absDiff.inMinutes == 1 ? '1 minute' : '${absDiff.inMinutes} minutes';
    } else {
      return 'just now';
    }

    return isPast ? '$timeStr ago' : 'in $timeStr';
  }

  /// Format duration in minutes to readable string (e.g., "1h 30m").
  static String duration(int? minutes) {
    if (minutes == null || minutes <= 0) return '0m';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  /// Format duration in seconds to mm:ss format.
  static String timerDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '0:00';

    final mins = seconds ~/ 60;
    final secs = seconds % 60;

    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  /// Format weight with unit (e.g., "135 lbs" or "61.2 kg").
  static String weight(double? weight, {String unit = 'lbs', int decimals = 1}) {
    if (weight == null) return '';
    return '${weight.toStringAsFixed(decimals)} $unit';
  }

  /// Format distance (e.g., "1.5 mi" or "2.4 km").
  static String distance(double? distance, {String unit = 'mi', int decimals = 1}) {
    if (distance == null) return '';
    return '${distance.toStringAsFixed(decimals)} $unit';
  }

  /// Format calories (e.g., "350 cal" or "1.2K cal").
  static String calories(int? calories) {
    if (calories == null) return '';
    if (calories >= 1000) {
      return '${(calories / 1000).toStringAsFixed(1)}K cal';
    }
    return '$calories cal';
  }

  /// Format a number with thousands separator (e.g., "1,234,567").
  static String number(num? value) {
    if (value == null) return '';
    return NumberFormat('#,###').format(value);
  }

  /// Format a percentage (e.g., "75%").
  static String percentage(double? value, {int decimals = 0}) {
    if (value == null) return '';
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format body metric (height in cm or ft/in based on unit).
  static String height(double? cm, {bool useImperial = false}) {
    if (cm == null) return '';

    if (useImperial) {
      final totalInches = cm / 2.54;
      final feet = totalInches ~/ 12;
      final inches = (totalInches % 12).round();
      return '$feet\' $inches"';
    }

    return '${cm.round()} cm';
  }

  /// Format workout volume (total weight lifted).
  static String volume(double? volume) {
    if (volume == null || volume == 0) return '0';

    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }

    return number(volume.round());
  }

  /// Format sets and reps (e.g., "3 x 10" or "3x10").
  static String setsReps(int? sets, int? reps, {bool compact = false}) {
    if (sets == null || reps == null) return '';
    return compact ? '${sets}x$reps' : '$sets x $reps';
  }

  /// Truncate text with ellipsis.
  static String truncate(String? text, int maxLength) {
    if (text == null || text.isEmpty) return '';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Capitalize first letter of each word.
  static String titleCase(String? text) {
    if (text == null || text.isEmpty) return '';
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Format ordinal number (e.g., "1st", "2nd", "3rd").
  static String ordinal(int? number) {
    if (number == null) return '';

    final suffix = switch (number % 100) {
      11 || 12 || 13 => 'th',
      _ => switch (number % 10) {
          1 => 'st',
          2 => 'nd',
          3 => 'rd',
          _ => 'th',
        },
    };

    return '$number$suffix';
  }
}
