import 'dart:async';

import 'package:flutter/material.dart' show Color, Colors, FontWeight, TextStyle;
import 'package:zebra_scanner/core/models/suggestion.dart';
import 'package:zebra_scanner/settings.dart' as localSettings;

class Settings {
  static const defaultApiServer = localSettings.apiServer;
  static const serverConnectTimeout = 3000; // In milliseconds
  static const sendLogsType = SendLogsType.json;
  static const keepOldLogs = false;
  static const sendLogsToServer = localSettings.enableSendLogs;
  static const sendLogsToServerDuration = Duration(hours: 1);
  static const defaultFlashMessageDuration = Duration(seconds: 3);
  static const sentryDsn = localSettings.sentryDsn;
}

class LocalStorageKeys {
  static const apiServerKey = "serverAddress";
  static const firstLogDateTimeKey = "firstLogDateTime";
  static const secureKey = "secureKey";
  static const languageKey = "language";
}

class Styles {
  static const alertMessageText = TextStyle(
    fontWeight: FontWeight.bold,
    color: Color(alertMessageTextColor),
  );
  // Button colors
  static const largeButtonColor = Colors.orange;
  static const leftButtonColor = Colors.red;
  static const middleButtonColor = Colors.lightBlue;
  static const rightButtonColor = Colors.green;

  // Other colors
  static const scannerColor = "#ff6666";
  static const alertMessageTextColor = 0xFFC52807;
  static const normalMessageTextColor = 0xFF000000;
  static const appColor = Colors.blue;
}

class Routes {
  static const home = "/";
  static const barcode = "/barcode";
  static const example = "/example";
}

enum FooterType { empty, buttons, deviceId }
enum SendLogsType { json, file }

typedef VoidCallback = Function();
typedef StringCallback = Function(String code);
typedef NumberCallback = Function(int code);
typedef BoolCallback = Function(bool value);
typedef SuggestionCallback = FutureOr<Iterable<Suggestion>> Function(String code);