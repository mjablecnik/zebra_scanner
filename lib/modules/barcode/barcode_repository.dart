import 'package:flutter_modular/flutter_modular.dart';
import 'package:sprintf/sprintf.dart';
import 'package:zebra_scanner/core/endpoints.dart';
import 'package:zebra_scanner/core/providers/http_provider.dart';
import 'package:zebra_scanner/modules/barcode/barcode_models.dart';

class BarcodeRepository {
  final HttpProvider httpProvider = Modular.get<HttpProvider>();

  Future<List<BarcodeType>> getTypes() async {
    final response = await httpProvider.sendGet(BarcodeEndpoints.types);
    return [for (var type in response.data["types"]) BarcodeType.fromJson(type)];
  }

  Future<bool> registerCodes(BarcodeType type, List<Barcode> codes) async {
    try {
      final url = sprintf(BarcodeEndpoints.send, [type.id]);
      final response = await httpProvider.sendPost(url, {"codes": codes});
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }
}
