import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:invoice_maker/features/invoices/data/models/invoice_model.dart';
import 'package:invoice_maker/features/invoices/data/repositories/invoice_repository.dart';

part 'invoice_provider.g.dart';

@riverpod
class Invoices extends _$Invoices {
  late final InvoiceRepository _repository;

  @override
  FutureOr<List<InvoiceModel>> build() async {
    _repository = InvoiceRepository();
    return _repository.getAllInvoices();
  }

  Future<void> saveInvoice(InvoiceModel invoice) async {
    await _repository.saveInvoice(invoice);
    ref.invalidateSelf();
  }
}
