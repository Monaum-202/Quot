import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../models/template_model.dart';
import '../../../quotations/data/models/line_item_model.dart';
import 'package:uuid/uuid.dart';

class TemplateRepository {
  final Box<TemplateModel> _box = Hive.box(HiveBoxNames.templates);

  List<TemplateModel> get templates => _box.values.toList();

  Future<void> seedTemplatesIfEmpty() async {
    if (_box.isEmpty) {
      final defaultTemplates = [
        TemplateModel(
          id: const Uuid().v4(),
          name: 'House Construction',
          description: 'Basic foundation to roofing',
          defaultItems: [
            LineItemModel(description: 'Foundation Work', quantity: 1, unit: 'ls', unitPrice: 0),
            LineItemModel(description: 'Brickwork', quantity: 1, unit: 'sqft', unitPrice: 0),
            LineItemModel(description: 'Plastering', quantity: 1, unit: 'sqft', unitPrice: 0),
            LineItemModel(description: 'Roofing', quantity: 1, unit: 'sqft', unitPrice: 0),
          ],
          createdAt: DateTime.now(),
        ),
        TemplateModel(
          id: const Uuid().v4(),
          name: 'Electrical Installation',
          description: 'Wiring and point fixing',
          defaultItems: [
            LineItemModel(description: 'Main Wiring', quantity: 1, unit: 'job', unitPrice: 0),
            LineItemModel(description: 'Light Points', quantity: 1, unit: 'pcs', unitPrice: 0),
            LineItemModel(description: 'Fan Points', quantity: 1, unit: 'pcs', unitPrice: 0),
            LineItemModel(description: 'DB Board Setup', quantity: 1, unit: 'pcs', unitPrice: 0),
          ],
          createdAt: DateTime.now(),
        ),
        TemplateModel(
          id: const Uuid().v4(),
          name: 'Painting Work',
          description: 'Wall preparation and painting',
          defaultItems: [
            LineItemModel(description: 'Wall Scrapping', quantity: 1, unit: 'sqft', unitPrice: 0),
            LineItemModel(description: 'Primer Coat', quantity: 1, unit: 'sqft', unitPrice: 0),
            LineItemModel(description: 'Plastic Paint (2 Coats)', quantity: 1, unit: 'sqft', unitPrice: 0),
          ],
          createdAt: DateTime.now(),
        ),
      ];

      for (var t in defaultTemplates) {
        await _box.put(t.id, t);
      }
    }
  }

  Future<void> addTemplate(TemplateModel template) async {
    await _box.put(template.id, template);
  }

  Future<void> deleteTemplate(String id) async {
    await _box.delete(id);
  }
}
