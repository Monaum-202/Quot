import 'package:hive/hive.dart';

part 'line_item_model.g.dart';

@HiveType(typeId: 3)
class LineItemModel {
  @HiveField(0)
  String description;
  @HiveField(1)
  double quantity;
  @HiveField(2)
  String unit;
  @HiveField(3)
  double unitPrice;

  LineItemModel({
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}
