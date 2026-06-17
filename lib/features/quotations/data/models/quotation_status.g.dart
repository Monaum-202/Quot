// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuotationStatusAdapter extends TypeAdapter<QuotationStatus> {
  @override
  final int typeId = 6;

  @override
  QuotationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuotationStatus.draft;
      case 1:
        return QuotationStatus.sent;
      case 2:
        return QuotationStatus.approved;
      case 3:
        return QuotationStatus.rejected;
      case 4:
        return QuotationStatus.convertedToInvoice;
      default:
        return QuotationStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, QuotationStatus obj) {
    switch (obj) {
      case QuotationStatus.draft:
        writer.writeByte(0);
        break;
      case QuotationStatus.sent:
        writer.writeByte(1);
        break;
      case QuotationStatus.approved:
        writer.writeByte(2);
        break;
      case QuotationStatus.rejected:
        writer.writeByte(3);
        break;
      case QuotationStatus.convertedToInvoice:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
