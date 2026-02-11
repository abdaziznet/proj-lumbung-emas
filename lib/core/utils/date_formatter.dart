import 'package:intl/intl.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';

/// Date formatter utility
class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat(AppConstants.dateFormat);
  static final DateFormat _dateTimeFormat = DateFormat(AppConstants.dateTimeFormat);
  static final DateFormat _apiFormat = DateFormat(AppConstants.apiDateFormat);
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// Format date for display
  /// Example: 2024-02-11 -> 11 Feb 2024
  static String formatDate(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Format date and time for display
  /// Example: 2024-02-11 14:30 -> 11 Feb 2024 14:30
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Format date for API calls
  /// Example: 2024-02-11 -> 2024-02-11
  static String formatForApi(DateTime date) {
    return _apiFormat.format(date);
  }

  /// Format time only
  /// Example: 14:30
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Parse API date string
  /// Example: "2024-02-11" -> DateTime
  static DateTime? parseApiDate(String dateString) {
    try {
      return _apiFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time string
  /// Example: "2 hours ago", "Yesterday", "3 days ago"
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }
}
