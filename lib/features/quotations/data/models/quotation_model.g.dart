// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuotationModelAdapter extends TypeAdapter<QuotationModel> {
  @override
  final int typeId = 2;

  @override
  QuotationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuotationModel(
      id: fields[0] as String,
      quotationNumber: fields[1] as String,
      customerId: fields[2] as String,
      customerName: fields[3] as String,
      projectName: fields[4] as String,
      items: (fields[5] as List).cast<LineItemModel>(),
      discountAmount: fields[6] as double,
      taxPercent: fields[7] as double,
      notes: fields[8] as String?,
      status: fields[9] as QuotationStatus,
      createdAt: fields[10] as DateTime,
      validUntil: fields[11] as DateTime,
      photoPaths: (fields[12] as List).cast<String>(),
      signaturePath: fields[13] as String?,
      pdfPath: fields[14] as String?,
      isConvertedToInvoice: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QuotationModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quotationNumber)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.customerName)
      ..writeByte(4)
      ..write(obj.projectName)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.discountAmount)
      ..writeByte(7)
      ..write(obj.taxPercent)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.validUntil)
      ..writeByte(12)
      ..write(obj.photoPaths)
      ..writeByte(13)
      ..write(obj.signaturePath)
      ..writeByte(14)
      ..write(obj.pdfPath)
      ..writeByte(15)
      ..write(obj.isConvertedToInvoice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
