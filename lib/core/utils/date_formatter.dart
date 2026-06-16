import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }
}
