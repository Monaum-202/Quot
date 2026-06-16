import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/company_model.dart';
import '../data/repositories/company_repository.dart';

part 'company_provider.g.dart';

@riverpod
class Company extends _$Company {
  late final CompanyRepository _repository;

  @override
  CompanyModel? build() {
    _repository = CompanyRepository();
    return _repository.company;
  }

  Future<void> saveCompany(CompanyModel company) async {
    await _repository.saveCompany(company);
    state = company;
  }
}
