import 'package:flutter/services.dart' show SystemNavigator;
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/core/utils/utils.dart';

class LifecycleWidget extends StatefulWidget {
  final Widget child;
  final Function? backAction;
  final bool enableQuitAction;

  const LifecycleWidget({
    Key? key,
    required this.child,
    this.backAction,
    this.enableQuitAction = false,
  }) : super(key: key);

  @override
  _LifecycleWidgetState createState() => _LifecycleWidgetState();
}

class _LifecycleWidgetState extends State<LifecycleWidget> with LifecycleMixin {
  @override
  initState() {
    super.initState();
    BackButtonInterceptor.add(backActionWrapper);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backActionWrapper);
    super.dispose();
  }

  Future<bool> backActionWrapper(bool stopDefaultButtonEvent, RouteInfo info) async {
    if (stopDefaultButtonEvent) return true;
    await Utils.exceptionHandler(widget.backAction ?? defaultBackAction);
    return true;
  }

  defaultBackAction() async {
    logger.info(LogAction.press("Back", buttonType: ButtonType.hardware));
    if (Modular.to.canPop()) {
      Modular.to.pop();
      logger.info(LogAction.goBack("Through pop()"));
    } else if (widget.enableQuitAction) {
      logger.info(LogAction.dialog(translate.app.alerts.quitAppQuestion));
      final quit = await MyDialog.of(context).confirm(
        Text(
          translate.app.alerts.quitAppQuestion,
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(Styles.alertMessageTextColor)),
        ),
        cancelText: translate.core.buttons.no,
        buttonText: translate.core.buttons.yes,
      );
      if (quit == true) {
        SystemNavigator.pop();
      }
      logger.info(LogAction.press(
        quit == true ? translate.core.buttons.yes : translate.core.buttons.no,
        buttonType: ButtonType.dialog,
      ));
    }
  }

  @override
  void onContextReady() {
    debugPrint('context ready');
  }

  @override
  void onPause() {
    debugPrint('did pause');
  }

  @override
  void onResume() {
    debugPrint('did resume');
  }

  @override
  void onDetached() {
    debugPrint('detached');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        logger.info(LogAction.goBack("Into previous page"));
        return true;
      },
      child: widget.child,
    );
  }
}
