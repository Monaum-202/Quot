import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/customer_model.dart';
import '../data/repositories/customer_repository.dart';

part 'customer_provider.g.dart';

@riverpod
class Customers extends _$Customers {
  late final CustomerRepository _repository;

  @override
  List<CustomerModel> build() {
    _repository = CustomerRepository();
    return _repository.customers;
  }

  void refresh() {
    state = _repository.customers;
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _repository.addCustomer(customer);
    refresh();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _repository.updateCustomer(customer);
    refresh();
  }

  Future<void> deleteCustomer(String id) async {
    await _repository.deleteCustomer(id);
    refresh();
  }
}
