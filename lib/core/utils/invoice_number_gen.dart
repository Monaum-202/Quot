import 'package:hive/hive.dart';
import '../constants/hive_box_names.dart';

class InvoiceNumberGen {
  static String generate() {
    final box = Hive.box(HiveBoxNames.settings);
    int counter = box.get('inv_counter', defaultValue: 0) + 1;
    box.put('inv_counter', counter);
    final year = DateTime.now().year;
    return 'INV-$year-${counter.toString().padLeft(3, '0')}';
  }
}
