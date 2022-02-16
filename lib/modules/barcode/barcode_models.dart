import 'package:json_annotation/json_annotation.dart';

part 'barcode_models.g.dart';

@JsonSerializable()
class Barcode {
  final String code;
  String note;

  Barcode(this.code, [this.note = ""]);

  factory Barcode.fromJson(Map<String, dynamic> json) => _$BarcodeFromJson(json);
  Map<String, dynamic> toJson() => _$BarcodeToJson(this);

  @override
  String toString() {
    return this.toJson().toString();
  }
}

@JsonSerializable()
class BarcodeType {
  final String id;
  final String name;

  const BarcodeType(this.id, this.name);

  factory BarcodeType.fromJson(Map<String, dynamic> json) => _$BarcodeTypeFromJson(json);
  Map<String, dynamic> toJson() => _$BarcodeTypeToJson(this);
}
