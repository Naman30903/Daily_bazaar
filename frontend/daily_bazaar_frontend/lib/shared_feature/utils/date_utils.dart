/// IST date/time formatting utilities.
class ISTDateUtils {
  ISTDateUtils._();

  /// IST offset: UTC+5:30
  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  static DateTime toIST(DateTime dt) {
    return dt.toUtc().add(_istOffset);
  }

  static String formatDateTime(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = toIST(DateTime.parse(isoDate));
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:${dt.minute.toString().padLeft(2, '0')} $amPm';
    } catch (_) {
      return isoDate;
    }
  }

  static String formatDateOnly(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = toIST(DateTime.parse(isoDate));
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  static String formatTimeOnly(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = toIST(DateTime.parse(isoDate));
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:${dt.minute.toString().padLeft(2, '0')} $amPm';
    } catch (_) {
      return isoDate;
    }
  }
}

/// Format amount from cents/paise to rupees display string.
String formatRupees(num cents) {
  final rupees = cents / 100;
  if (rupees == rupees.truncateToDouble()) {
    return '₹${rupees.toStringAsFixed(0)}';
  }
  return '₹${rupees.toStringAsFixed(2)}';
}
