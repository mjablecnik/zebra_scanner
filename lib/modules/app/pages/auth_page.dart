import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:zebra_scanner/core/exceptions.dart';
import 'package:zebra_scanner/components/scan_code/scan_code_store.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/components/scan_code/scan_code_page.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/core/utils/messages.dart';
import 'package:zebra_scanner/modules/app/user_store.dart';
import 'package:zebra_scanner/core/utils/utils.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late ScanCodeStore _scanStore;
  final UserStore userStore = Modular.get<UserStore>();

  @override
  initState() {
    super.initState();
    _scanStore = ScanCodeStore();
    _scanStore.nextScan(
      message: translate.app.auth.message,
      callback: this.loginWithCode,
      quitAppEnabled: true,
    );
  }

  Future<void> showRegisterDeviceDialog() async {
    logger.info(LogAction.dialog(translate.app.auth.registerDialog.message));

    bool? result = await MyDialog.of(context).confirm(
      translate.app.auth.registerDialog.message,
      buttonText: translate.app.auth.registerDialog.confirm,
      cancelText: translate.app.auth.registerDialog.cancel,
    );

    logger.info(LogAction.press(
      result == true ? translate.app.auth.registerDialog.confirm : translate.app.auth.registerDialog.cancel,
      buttonType: ButtonType.dialog,
    ));

    if (result != null && result) {
      bool result = await userStore.registerDevice();
      if (result) {
        logger.info(LogAction.flash(translate.app.auth.registerDeviceSuccess));
        FlashMessage(translate.app.auth.registerDeviceSuccess).show(context);
      } else {
        logger.info(LogAction.flash(translate.app.auth.registerDeviceError));
        FlashMessage(translate.app.auth.registerDeviceSuccess).show(context);
      }
    }
  }

  loginWithCode(String code) async {
    try {
      await userStore.loginWithCode(code);
    } on WrongCodeException {
      Utils.showAlertDialog(context, translate.components.scanCode.wrong);
    } on UnknownDeviceException {
      _scanStore.setLoading(false);
      await showRegisterDeviceDialog();
    } on ServerException catch (e) {
      _scanStore.setLoading(false);
      Utils.showAlertDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScanCodePage(store: _scanStore);
  }
}
