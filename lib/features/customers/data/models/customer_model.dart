import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 1)
class CustomerModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String phone;
  @HiveField(3)
  String address;
  @HiveField(4)
  String? email;
  @HiveField(5)
  DateTime createdAt;
  @HiveField(6)
  List<String> quotationIds;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.email,
    required this.createdAt,
    required this.quotationIds,
  });
}
