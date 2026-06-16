import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _bdtFormat = NumberFormat.currency(
    locale: 'en_BD',
    symbol: '৳',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _bdtFormat.format(amount);
  }
}
