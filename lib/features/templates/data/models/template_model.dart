import 'package:hive/hive.dart';
import '../../../quotations/data/models/line_item_model.dart';

part 'template_model.g.dart';

@HiveType(typeId: 4)
class TemplateModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String? description;
  @HiveField(3)
  List<LineItemModel> defaultItems;
  @HiveField(4)
  DateTime createdAt;

  TemplateModel({
    required this.id,
    required this.name,
    this.description,
    required this.defaultItems,
    required this.createdAt,
  });
}
