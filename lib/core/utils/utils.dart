import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart' show BuildContext, MediaQuery, Size, Text, showDialog;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:crypto/crypto.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:zebra_scanner/components/language_dialog.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/exceptions.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';

class Utils {
  static final isUnitTestsRunning = Platform.environment.containsKey('FLUTTER_TEST');

  static Future<String> getDeviceId() async {
    final String? deviceId = await PlatformDeviceId.getDeviceId;
    if (deviceId == null || deviceId.isEmpty) {
      throw DeviceIdException;
    }

    final bytes = utf8.encode(deviceId); // data being hashed
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  static computeButtonSize(BuildContext context, {required int numberOfButtonsInRow}) {
    final spaces = numberOfButtonsInRow == 1 ? 16 : 12;
    return Size(MediaQuery.of(context).size.width / numberOfButtonsInRow - spaces, 50);
  }

  static playAlertSound() {
    logger.info(LogAction.process("Play alert sound"));
    FlutterBeep.beep(false);
  }

  static showAlertDialog(BuildContext context, String message) {
    logger.error(LogAction.dialog(message));
    MyDialog.of(context).alert(Text(message, style: Styles.alertMessageText));
  }

  static String getRandomString(int length) {
    var random = Random.secure();
    var values = List<int>.generate(length, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  static changeLanguage(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return LanguageDialog();
      },
    );
  }

  static Future<String> getSecuredKey() async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: LocalStorageKeys.secureKey);
    if (!containsEncryptionKey) {
      final value = Utils.getRandomString(Random().nextInt(50) + 100);
      await secureStorage.write(key: LocalStorageKeys.secureKey, value: value);
    }

    return (await secureStorage.read(key: LocalStorageKeys.secureKey)) as String;
  }

  static exceptionHandler(Function callback) async {
    try {
      return await callback.call();
    } catch (exception, stackTrace) {
      await captureException(exception, stackTrace);
    }
  }

  static captureException(exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);

    //final userStore = Modular.get<UserStore>();
    //final SentryId eventId = await Sentry.captureException(exception, stackTrace: stackTrace);
    //final userFeedback = SentryUserFeedback(
    //  eventId: eventId,
    //  comments: 'Hello World!',
    //  name: userStore.currentUser.username,
    //);

    //Sentry.captureUserFeedback(userFeedback);
  }
}
