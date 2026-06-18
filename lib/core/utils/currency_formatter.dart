import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = 'SR'}) {
    final format = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return format.format(amount);
  }
}
