import 'package:hive/hive.dart';
import '../../../quotations/data/models/line_item_model.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 5)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String invoiceNumber;
  @HiveField(2)
  String quotationId;
  @HiveField(3)
  String customerId;
  @HiveField(4)
  String customerName;
  @HiveField(5)
  String projectName;
  @HiveField(6)
  List<LineItemModel> items;
  @HiveField(7)
  double discountAmount;
  @HiveField(8)
  double taxPercent;
  @HiveField(9)
  double paidAmount;
  @HiveField(10)
  DateTime issuedAt;
  @HiveField(11)
  DateTime dueDate;
  @HiveField(12)
  String? notes;
  @HiveField(13)
  String? pdfPath;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.quotationId,
    required this.customerId,
    required this.customerName,
    required this.projectName,
    required this.items,
    this.discountAmount = 0,
    this.taxPercent = 0,
    this.paidAmount = 0,
    required this.issuedAt,
    required this.dueDate,
    this.notes,
    this.pdfPath,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get grandTotal =>
      subtotal - discountAmount + (subtotal * taxPercent / 100);
  double get balanceDue => grandTotal - paidAmount;
}
