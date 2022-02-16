import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/components/scan_code/scan_code_page.dart';
import 'package:zebra_scanner/modules/barcode/select_barcode_type_page.dart';
import 'package:zebra_scanner/modules/barcode/barcode_repository.dart';
import 'package:zebra_scanner/modules/barcode/barcode_store.dart';
import 'package:zebra_scanner/modules/barcode/constants.dart';

class BarcodeModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.singleton((i) => BarcodeRepository()),
    Bind.singleton((i) => BarcodeStore()),
  ];

  @override
  List<ModularRoute> get routes => [
    ChildRoute(SubRoutes.selectType, child: (_, args) => SelectBarcodeTypePage()),
    ChildRoute(SubRoutes.registration, child: (_, args) => ScanCodePage(store: Modular.get<BarcodeStore>())),
  ];
}
