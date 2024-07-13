import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime parseDate(String date) {
    return DateFormat('yyyy-MM-dd').parse(date);
  }
}
