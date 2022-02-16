import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/services/connection_service.dart';
import 'package:zebra_scanner/core/services/data_wedge_service.dart';
import 'package:zebra_scanner/core/providers/http_provider.dart';
import 'package:zebra_scanner/core/services/log_sender_service.dart';
import 'package:zebra_scanner/modules/app/auth_repository.dart';
import 'package:zebra_scanner/modules/app/module.dart';
import 'package:zebra_scanner/modules/barcode/module.dart';
import 'package:zebra_scanner/modules/example/module.dart';
import 'modules/app/user_store.dart';

class MainModule extends Module {
  // Provide a list of dependencies to inject into your project
  @override
  List<Bind> get binds => [
    // Global singletons
    Bind.singleton((i) => UserStore()),
    Bind.singleton((i) => AuthRepository()),

    // Core services
    Bind.singleton((i) => HttpProvider()),
    Bind.singleton((i) => LogSenderService()),
    Bind.singleton((i) => DataWedgeService()),
    Bind.singleton((i) => ConnectionService()),
  ];

  // Provide all the routes for your module
  @override
  List<ModularRoute> get routes => [
    ModuleRoute(Routes.home, module: AppModule()),
    ModuleRoute(Routes.barcode, module: BarcodeModule()),
    ModuleRoute(Routes.example, module: ExampleModule()),
  ];
}
