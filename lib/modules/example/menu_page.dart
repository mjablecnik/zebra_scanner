import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/components/menu/menu_item.dart';
import 'package:zebra_scanner/components/menu/menu_page.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/core/utils/extensions.dart';
import 'package:zebra_scanner/modules/example/constants.dart';

class ExampleMenuPage extends MenuPage {
  ExampleMenuPage()
      : super(items: [
          MenuItem(
            text: translate.example.menu.customDesign,
            callback: () => Modular.to.pushNamed(SubRoutes.customDesign.relative()),
          ),
          MenuItem(
            text: translate.example.menu.handover,
            callback: () => Modular.to.pushNamed(SubRoutes.handover.relative()),
          ),
        ]);
}
