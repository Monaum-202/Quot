import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:invoice_maker/features/quotations/data/models/quotation_model.dart';
import 'package:invoice_maker/features/quotations/data/repositories/quotation_repository.dart';

part 'quotation_provider.g.dart';

@riverpod
class Quotations extends _$Quotations {
  late final QuotationRepository _repository;

  @override
  FutureOr<List<QuotationModel>> build() async {
    _repository = QuotationRepository();
    return _repository.getAllQuotations();
  }

  Future<void> saveQuotation(QuotationModel quotation) async {
    await _repository.saveQuotation(quotation);
    ref.invalidateSelf();
  }

  Future<void> deleteQuotation(String id) async {
    await _repository.deleteQuotation(id);
    ref.invalidateSelf();
  }
}
