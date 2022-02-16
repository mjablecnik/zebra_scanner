import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/components/logs_page.dart';
import 'package:zebra_scanner/modules/app/auth_guard.dart';
import 'package:zebra_scanner/modules/app/constants.dart';
import 'package:zebra_scanner/modules/app/pages/auth_page.dart';
import 'package:zebra_scanner/modules/app/pages/home_page.dart';
import 'package:zebra_scanner/modules/app/pages/settings_page.dart';
import 'package:zebra_scanner/modules/app/pages/qr_code_page.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
    ChildRoute(AppRoutes.auth, child: (_, args) => AuthPage()),
    ChildRoute(AppRoutes.info, child: (_, args) => SettingsPage()),
    ChildRoute(AppRoutes.qrCode, child: (_, args) => QrCodePage(text: args.data)),
    ChildRoute(AppRoutes.home, child: (_, args) => HomePage(), guards: [AuthGuard()]),
    ChildRoute(AppRoutes.logs, child: (_, args) => LogsPage(), guards: [AuthGuard()]),
  ];
}
