import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/core/utils/messages.dart';
import 'package:zebra_scanner/core/utils/utils.dart';
import 'package:zebra_scanner/components/scan_code/scan_code_page.dart';

mixin Handlers on ScanCodePageState {
  late DialogController _loader;

  exceptionHandler(Function callback) async {
    try {
      store.setLoading(true);
      await callback();
    } on Exception catch (exception, stackTrace) {
      Utils.showAlertDialog(context, exception.toString());
      Utils.captureException(exception, stackTrace);
    } finally {
      store.setLoading(false);
    }
  }

  initMessageHandler() {
    final loadingMessage = translate.core.loading;

    store.observer(
      onLoading: (bool isLoading) {
        if (Utils.isUnitTestsRunning) return;

        if (isLoading == true) {
          _loader = MyDialog.of(context).loading(loadingMessage, time: 10);
        } else {
          try {
            _loader.remove();
          } catch (e) {
            print(e);
          }
        }
      },
      onError: (Message message) async {
        if (message is AlertMessage || message is NormalMessage) {
          MyDialog.of(context).alert(
            Text(
              message.text,
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(message.color)),
            ),
          );
        } else if (message is QuestionMessage) {
          final bool? value = await MyDialog.of(context).confirm(
            Text(
              message.text,
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(message.color)),
            ),
            cancelText: message.buttonTexts.first,
            buttonText: message.buttonTexts.last,
          );
          exceptionHandler(() async {
            logger.info(LogAction.press(
              value == true ? message.buttonTexts.last : message.buttonTexts.first,
              buttonType: ButtonType.dialog,
            ));
            await message.answer(value ?? false);
          });
        } else if (message is FlashMessage) {
          message.show(context);
        }
      },
    );
  }
}
