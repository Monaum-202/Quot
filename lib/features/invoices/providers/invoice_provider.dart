import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/invoice_model.dart';
import '../data/repositories/invoice_repository.dart';

part 'invoice_provider.g.dart';

@riverpod
class Invoices extends _$Invoices {
  late final InvoiceRepository _repository;

  @override
  Future<List<InvoiceModel>> build() async {
    _repository = InvoiceRepository();
    return _repository.getAllInvoices();
  }

  Future<void> saveInvoice(InvoiceModel invoice) async {
    await _repository.saveInvoice(invoice);
    ref.invalidateSelf();
  }
}
