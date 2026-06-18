import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final Box<CustomerModel> _box = Hive.box(HiveBoxNames.customers);

  List<CustomerModel> get customers => _box.values.toList();

  ValueListenable<Box<CustomerModel>> get listenable => _box.listenable();

  Future<void> addCustomer(CustomerModel customer) async {
    await _box.put(customer.id, customer);
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await customer.save();
  }

  Future<void> deleteCustomer(String id) async {
    await _box.delete(id);
  }
}
