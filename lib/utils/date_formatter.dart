import 'package:intl/intl.dart';

class DateFormatter {
  static DateTime? parse(String? dateString) {
    if (dateString == null) return null;
    
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (err) {
      return null;
    }
  }

  static String? format(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
