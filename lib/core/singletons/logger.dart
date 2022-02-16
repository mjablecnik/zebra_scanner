import 'package:my_logger/core/constants.dart';
import 'package:my_logger/logger.dart';
import 'package:zebra_scanner/core/utils/extensions.dart';
import 'package:zebra_scanner/main.dart';

final logger = Logger.instance;

class Logger {
  Logger._() {
    LogConfig config = MyLogger.config
      ..outputFormat = "{{level}} {{time}} - {{message}}"
      ..dataLogTypeValues = DataLogType.values
      ..timestampFormat = TimestampFormat.DEFAULT;

    if (encryptionKey != null) {
      config.encryption = EncryptionType.XXTEA;
      config.encryptionKey = encryptionKey!;
    }
    print("Logger was initialized.");

    MyLogger.applyConfig(config);
  }

  static final Logger _singleton = Logger._();

  static Logger get instance => _singleton;

  log(LogLevel level, Object object, [DataLogType? dataLogType]) {
    switch (object.runtimeType) {
      case LogAction:
        object as LogAction;
        MyLogger.log(
          type: level,
          dataLogType: DataLogType.ACTION,
          text: "${object.toString()}",
        );
        break;
      case String:
        final message = object as String;
        MyLogger.log(
          type: level,
          text: message,
          dataLogType: dataLogType ?? DataLogType.DEFAULT,
        );
    }
  }

  debug(Object object, {DataLogType? type}) => log(LogLevel.DEBUG, object, type);

  info(Object object, {DataLogType? type}) => log(LogLevel.INFO, object, type);

  warning(Object object, {DataLogType? type}) => log(LogLevel.WARNING, object, type);

  error(Object object, {DataLogType? type}) => log(LogLevel.ERROR, object, type);
}

class LogAction {
  const LogAction(this.type, this.message);

  final LogActionType type;
  final String? message;

  factory LogAction.dialog(String message) => LogAction(LogActionType.APP_OUTPUT_DIALOG_MESSAGE, message);

  factory LogAction.flash(String message) => LogAction(LogActionType.APP_OUTPUT_FLASH_MESSAGE, message);

  factory LogAction.screen(String message) => LogAction(LogActionType.APP_OUTPUT_SCREEN_MESSAGE, message);

  factory LogAction.data(Object object) => LogAction(LogActionType.APP_OUTPUT_DATA, object.toString());

  factory LogAction.input(String? value) => LogAction(LogActionType.USER_INPUT_TEXT, value);

  factory LogAction.select(String? description) => LogAction(LogActionType.USER_SELECT, description);

  factory LogAction.goToPage(String page) => LogAction(LogActionType.APP_PROCESS_SHOW_PAGE, page);

  factory LogAction.goBack([String? description]) => LogAction(LogActionType.APP_PROCESS_GO_BACK, description ?? '---');

  factory LogAction.process(String description) => LogAction(LogActionType.APP_PROCESS, description);

  factory LogAction.action(String description) => LogAction(LogActionType.USER_ACTION, description);

  factory LogAction.code(String? value, {required InputCodeType inputType}) {
    switch (inputType) {
      case InputCodeType.textInput:
        return LogAction(LogActionType.SCAN_CODE_BY_TEXT_INPUT, value);
      case InputCodeType.camera:
        return LogAction(LogActionType.SCAN_CODE_BY_CAMERA, value);
      case InputCodeType.scanner:
        return LogAction(LogActionType.SCAN_CODE_BY_SCANNER, value);
    }
  }

  factory LogAction.press(String buttonText, {ButtonType? buttonType}) {
    switch (buttonType) {
      case ButtonType.menu:
        return LogAction(LogActionType.USER_PRESS_MENU_BUTTON, buttonText);
      case ButtonType.dialog:
        return LogAction(LogActionType.USER_PRESS_DIALOG_BUTTON, buttonText);
      case ButtonType.hardware:
        return LogAction(LogActionType.USER_PRESS_HARDWARE_BUTTON, buttonText);
      case ButtonType.icon:
        return LogAction(LogActionType.USER_PRESS_ICON_BUTTON, buttonText);
      case null:
        return LogAction(LogActionType.USER_PRESS_BUTTON, buttonText);
    }
  }

  @override
  String toString() {
    return "${type.toString().split('.').last} -> ${message?.escapeEndLines()}";
  }
}

enum InputCodeType { textInput, camera, scanner }

enum ButtonType { menu, dialog, hardware, icon }

enum LogActionType {
  NONE,
  USER_PRESS_BUTTON,
  USER_PRESS_ICON_BUTTON,
  USER_PRESS_MENU_BUTTON,
  USER_PRESS_DIALOG_BUTTON,
  USER_PRESS_HARDWARE_BUTTON,
  USER_ACTION,
  USER_SELECT,
  USER_INPUT_TEXT,
  USER_INPUT_NUMBER,
  SCAN_CODE_BY_TEXT_INPUT,
  SCAN_CODE_BY_CAMERA,
  SCAN_CODE_BY_SCANNER,
  APP_OUTPUT_DATA,
  APP_OUTPUT_SCREEN_MESSAGE,
  APP_OUTPUT_DIALOG_MESSAGE,
  APP_OUTPUT_FLASH_MESSAGE,
  APP_PROCESS_SHOW_PAGE,
  APP_PROCESS_GO_BACK,
  APP_PROCESS
}

enum DataLogType { DEFAULT, NOTIFICATION, NETWORK, STORAGE, ACTION }
