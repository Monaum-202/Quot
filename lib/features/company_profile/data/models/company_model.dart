import 'package:hive/hive.dart';

part 'company_model.g.dart';

@HiveType(typeId: 0)
class CompanyModel extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String ownerName;
  @HiveField(2)
  String phone;
  @HiveField(3)
  String address;
  @HiveField(4)
  String? email;
  @HiveField(5)
  String? logoPath;
  @HiveField(6)
  String? signaturePath;
  @HiveField(7)
  String? taxNumber;
  @HiveField(8)
  String currency;

  CompanyModel({
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.address,
    this.email,
    this.logoPath,
    this.signaturePath,
    this.taxNumber,
    this.currency = 'BDT',
  });
}
