import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/components/layout.dart';
import 'package:zebra_scanner/components/menu/menu_item.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key, this.title, required this.items, this.enableBackButton = false}) : super(key: key);

  final String? title;
  final List<MenuItem> items;
  final bool enableBackButton;

  @override
  Widget build(BuildContext context) {
    logger.info(LogAction.goToPage(Modular.to.path));

    return Layout(
      enableMainMenu: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          if (title != null) SizedBox(height: 40),
          for (var item in items) item,
          Spacer(),
          if (enableBackButton)
            MenuItem(
              text: translate.core.buttons.back,
              callback: () => Modular.to.pop(),
              color: Colors.deepOrangeAccent,
            ),
          if (enableBackButton) SizedBox(height: 8),
        ],
      ),
    );
  }
}
