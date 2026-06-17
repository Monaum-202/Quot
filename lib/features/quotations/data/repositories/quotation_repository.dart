import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_maker/core/constants/hive_box_names.dart';
import 'package:invoice_maker/features/quotations/data/models/quotation_model.dart';

class QuotationRepository {
  final LazyBox<QuotationModel> _box = Hive.lazyBox<QuotationModel>(HiveBoxNames.quotations);

  Future<List<QuotationModel>> getAllQuotations() async {
    final quotations = <QuotationModel>[];
    for (var key in _box.keys) {
      final q = await _box.get(key);
      if (q != null) quotations.add(q);
    }
    // Sort by date descending
    quotations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return quotations;
  }

  Future<void> saveQuotation(QuotationModel quotation) async {
    await _box.put(quotation.id, quotation);
  }

  Future<void> deleteQuotation(String id) async {
    await _box.delete(id);
  }

  Future<QuotationModel?> getQuotation(String id) async {
    return await _box.get(id);
  }

  ValueListenable<Box<QuotationModel>> get listenable => Hive.box<QuotationModel>(HiveBoxNames.quotations).listenable();
}
