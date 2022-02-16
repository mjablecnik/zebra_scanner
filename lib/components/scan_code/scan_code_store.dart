import 'dart:async';
import 'dart:ui' show Color;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart' show Widget;
import 'package:flutter_triple/flutter_triple.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/models.dart';
import 'package:zebra_scanner/core/models/suggestion.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/core/utils/messages.dart';
import 'package:zebra_scanner/components/table.dart';

part 'scan_code_store.g.dart';

enum InputType { SCAN, OWN_BUTTONS, NUMBER_INPUT, TEXT_INPUT, TEXT_INPUT_WITH_AUTO_COMPLETE }

@CopyWith()
class ScanCodeState with EquatableMixin {
  final String message;
  final String? title;
  final Button? leftButton;
  final Button? middleButton;
  final Button? rightButton;
  final Button? largeButton;
  final Function? scanCallback;
  final Color? color;
  final bool? backButtonEnabled;
  final bool? quitAppEnabled;
  final SuggestionCallback? suggestionListCallback;
  final InputType type;
  final OwnTable? table;
  final List<Widget>? actions;

  const ScanCodeState({
    required this.message,
    this.title,
    this.leftButton,
    this.middleButton,
    this.rightButton,
    this.largeButton,
    this.scanCallback,
    this.table,
    this.actions,
    this.suggestionListCallback,
    this.backButtonEnabled = false,
    this.quitAppEnabled = false,
    this.color = Colors.black87,
    this.type = InputType.SCAN,
  });

  factory ScanCodeState.empty() {
    return ScanCodeState(
      message: "Here will be some message",
      middleButton: Button(translate.components.scanCode.buttons.input, () {}),
      rightButton: Button(translate.components.scanCode.buttons.scan, () {}),
    );
  }

  factory ScanCodeState.onlyScan({required String message, required Function callback, Button? thirdButton}) {
    return ScanCodeState(
      message: message,
      middleButton: Button(translate.components.scanCode.buttons.input, callback),
      rightButton: Button(translate.components.scanCode.buttons.scan, callback),
      largeButton: thirdButton,
    );
  }

  @override
  List<Object?> get props => [title, message, color, type, table];
}

class ScanCodeStore extends StreamStore<Message, ScanCodeState> with MementoMixin {
  ScanCodeStore({state = const ScanCodeState(message: "")}) : super(state);
  
  @override
  void setLoading(bool newLoading, {bool force = true}) {
    super.setLoading(newLoading, force: force);
  }

  @override
  void setError(Message newError, {bool force = true}) {
    super.setError(newError, force: force);
  }

  void undo() {
    super.undo();
  }

  logScreenMessage(Color? color, String message) {
    if (color == Colors.black87 || color == null) {
      logger.info(LogAction.screen(message));
    } else {
      logger.warning(LogAction.screen(message));
    }
  }

  nextScan({
    required String message,
    required StringCallback callback,
    Button? largeButton,
    Button? specialButton,
    OwnTable? table,
    String? title,
    List<Widget>? actions,
    bool withBackButton = false,
    bool quitAppEnabled = false,
    Color color = Colors.black87,
  }) async {
    logScreenMessage(color, message);
    update(ScanCodeState(
      message: message,
      leftButton: specialButton,
      middleButton: Button(translate.components.scanCode.buttons.input, callback),
      rightButton: Button(translate.components.scanCode.buttons.scan, callback),
      largeButton: largeButton,
      scanCallback: callback,
      table: table,
      backButtonEnabled: withBackButton,
      quitAppEnabled: quitAppEnabled,
      color: color,
      title: title,
      actions: actions,
    ));
  }

  ownButtons({
    required String message,
    Button? leftButton,
    Button? middleButton,
    Button? rightButton,
    Button? largeButton,
    OwnTable? table,
    Color? color,
    bool? withBackButton,
  }) async {
    logScreenMessage(color, message);
    update(ScanCodeState(
      message: message,
      leftButton: leftButton,
      middleButton: middleButton,
      rightButton: rightButton,
      largeButton: largeButton,
      backButtonEnabled: withBackButton,
      table: table,
      color: color,
      type: InputType.OWN_BUTTONS,
    ));
  }

  takeInputText({
    required String message,
    required Button submitButton,
    Button? specialButton,
    Color? color,
    bool? withBackButton,
    SuggestionCallback? suggestionListCallback,
    InputType type = InputType.TEXT_INPUT,
  }) async {
    logScreenMessage(color, message);
    update(ScanCodeState(
      message: message,
      leftButton: specialButton,
      rightButton: submitButton,
      backButtonEnabled: withBackButton,
      suggestionListCallback: suggestionListCallback,
      color: color,
      type: suggestionListCallback == null ? type : InputType.TEXT_INPUT_WITH_AUTO_COMPLETE,
    ));
  }

  takeInputNumber({
    required String message,
    required NumberCallback callback,
    String? submitButtonText,
    Button? specialButton,
    Color? color,
    bool? withBackButton,
  }) async {
    takeInputText(
      message: message,
      color: color,
      specialButton: specialButton,
      withBackButton: withBackButton,
      type: InputType.NUMBER_INPUT,
      submitButton: Button(submitButtonText ?? translate.core.buttons.agree, (String? text) async {
        if (text != null && text.isNotEmpty) {
          int? parsedNumber;
          try {
            parsedNumber = int.parse(text);
          } on FormatException catch (_) {
            showFlashMessage(translate.core.alerts.wrongNumberInput);
          }
          if (parsedNumber != null) {
            await callback(parsedNumber);
          }
        }
      }),
    );
  }

  showAlert(String message) {
    logger.warning(LogAction.dialog(message));
    this.setError(AlertMessage(message));
  }

  showMessage(String message) {
    logger.info(LogAction.dialog(message));
    this.setError(NormalMessage(message));
  }

  showFlashMessage(String message) {
    logger.info(LogAction.flash(message));
    this.setError(FlashMessage(message));
  }

  askQuestion({required String message, required Function answer}) {
    logger.info(LogAction.dialog(message));
    this.setError(QuestionMessage.create(message, answer));
  }

  askAlertQuestion({required String message, Button? cancelButton, required Button confirmButton}) {
    logger.warning(LogAction.dialog(message));
    this.setError(QuestionMessage.custom(
      message,
      cancelButton: cancelButton ?? Button.no(() {}),
      confirmButton: confirmButton,
      textColor: Styles.alertMessageTextColor,
    ));
  }
}
