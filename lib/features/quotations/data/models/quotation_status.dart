import 'package:hive/hive.dart';

part 'quotation_status.g.dart';

@HiveType(typeId: 6)
enum QuotationStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  sent,
  @HiveField(2)
  approved,
  @HiveField(3)
  rejected,
  @HiveField(4)
  convertedToInvoice,
}
