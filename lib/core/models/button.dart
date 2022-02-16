import 'package:zebra_scanner/core/i18n/strings.g.dart';

class Button {
  final String text;
  final Function callback;

  const Button(this.text, this.callback);

  factory Button.yes(callback) {
    return Button(translate.core.buttons.yes, callback);
  }

  factory Button.no(callback) {
    return Button(translate.core.buttons.no, callback);
  }
}
