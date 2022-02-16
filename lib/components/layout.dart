import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/components/main_menu.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:zebra_scanner/components/lifecycle.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';

class Layout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? footer;
  final Widget? backButton;
  final Function? backAction;
  final bool enableQuitAction;
  final bool enableMainMenu;

  const Layout({
    Key? key,
    required this.child,
    this.title,
    this.actions,
    this.footer,
    this.backButton,
    this.backAction,
    this.enableQuitAction = false,
    this.enableMainMenu = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.info(LogAction.goToPage(Modular.to.path));
    bool isMainMenuOpened = false;

    return LifecycleWidget(
      backAction: backAction,
      enableQuitAction: enableQuitAction,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title ?? translate.app.title),
          centerTitle: true,
          leading: backButton,
          actions: actions ?? [],
        ),
        body: Column(
          children: [
            Expanded(child: Center(child: child)),
            footer ?? SizedBox(),
          ],
        ),
        drawer: enableMainMenu ? Drawer(child: MainMenu()) : null,
        onDrawerChanged: (bool isOpened) {
          if (isOpened && !isMainMenuOpened) {
            logger.info(LogAction.action('open_main_menu'));
            isMainMenuOpened = true;
          }
          if (!isOpened && isMainMenuOpened) {
            logger.info(LogAction.action('close_main_menu'));
            isMainMenuOpened = false;
          }
        },
      ),
    );
  }
}
