import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/modules/example/constants.dart';
import 'package:zebra_scanner/modules/example/handover/ui/handover_page.dart';
import 'package:zebra_scanner/modules/example/custom_design/home.dart';
import 'package:zebra_scanner/modules/example/handover/handover_repository.dart';
import 'package:zebra_scanner/modules/example/handover/ui/signature_page.dart';
import 'package:zebra_scanner/modules/example/menu_page.dart';

class ExampleModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.singleton((i) => HandOverRepository()),
  ];

  @override
  List<ModularRoute> get routes => [
    ChildRoute(SubRoutes.customDesign, child: (_, args) => HomePage()),
    ChildRoute(SubRoutes.menu, child: (_, args) => ExampleMenuPage()),
    ChildRoute(SubRoutes.handover, child: (_, args) => HandOverPage()),
    ChildRoute(SubRoutes.signature, child: (_, args) => SignaturePage()),
  ];
}
