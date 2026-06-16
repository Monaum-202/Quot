import 'package:hive/hive.dart';
import '../constants/hive_box_names.dart';

class QuotationNumberGen {
  static String generate() {
    final box = Hive.box(HiveBoxNames.settings);
    int counter = box.get('qt_counter', defaultValue: 0) + 1;
    box.put('qt_counter', counter);
    final year = DateTime.now().year;
    return 'QT-$year-${counter.toString().padLeft(3, '0')}';
  }
}
