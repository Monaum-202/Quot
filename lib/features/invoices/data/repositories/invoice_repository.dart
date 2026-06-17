import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final LazyBox<InvoiceModel> _box = Hive.lazyBox<InvoiceModel>(HiveBoxNames.invoices);

  Future<List<InvoiceModel>> getAllInvoices() async {
    final invoices = <InvoiceModel>[];
    for (var key in _box.keys) {
      final i = await _box.get(key);
      if (i != null) invoices.add(i);
    }
    invoices.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return invoices;
  }

  Future<void> saveInvoice(InvoiceModel invoice) async {
    await _box.put(invoice.id, invoice);
  }

  Future<void> deleteInvoice(String id) async {
    await _box.delete(id);
  }
}
