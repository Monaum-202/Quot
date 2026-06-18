import 'package:hive/hive.dart';
import 'line_item_model.dart';
import 'quotation_status.dart';

part 'quotation_model.g.dart';

@HiveType(typeId: 2)
class QuotationModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String quotationNumber;
  @HiveField(2)
  String customerId;
  @HiveField(3)
  String customerName;
  @HiveField(4)
  String projectName;
  @HiveField(5)
  List<LineItemModel> items;
  @HiveField(6)
  double discountAmount;
  @HiveField(7)
  double taxPercent;
  @HiveField(8)
  String? notes;
  @HiveField(9)
  QuotationStatus status;
  @HiveField(10)
  DateTime createdAt;
  @HiveField(11)
  DateTime validUntil;
  @HiveField(12)
  List<String> photoPaths;
  @HiveField(13)
  String? signaturePath;
  @HiveField(14)
  String? pdfPath;
  @HiveField(15)
  bool isConvertedToInvoice;
  @HiveField(16)
  bool showItemPrices;
  @HiveField(17)
  double? manualSubtotal;
  @HiveField(18)
  List<String> conditions;

  QuotationModel({
    required this.id,
    required this.quotationNumber,
    required this.customerId,
    required this.customerName,
    required this.projectName,
    required this.items,
    this.discountAmount = 0,
    this.taxPercent = 0,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.validUntil,
    required this.photoPaths,
    this.signaturePath,
    this.pdfPath,
    this.isConvertedToInvoice = false,
    this.showItemPrices = true,
    this.manualSubtotal,
    this.conditions = const [],
  });

  double get subtotal => manualSubtotal ?? items.fold(0, (sum, item) => sum + item.total);
  double get grandTotal =>
      subtotal - discountAmount + (subtotal * taxPercent / 100);
}
