// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LineItemModelAdapter extends TypeAdapter<LineItemModel> {
  @override
  final int typeId = 3;

  @override
  LineItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LineItemModel(
      description: fields[0] as String,
      quantity: fields[1] as double,
      unit: fields[2] as String,
      unitPrice: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LineItemModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.unitPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
