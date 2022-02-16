import 'package:another_flushbar/flushbar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/core/constants.dart';

import '../models.dart';

abstract class Message with EquatableMixin implements Exception {
  final String text;
  final DateTime createdAt = DateTime.now();
  final int color;

  Message(this.text, {this.color = Styles.normalMessageTextColor});

  @override
  List<Object?> get props => [text, createdAt, color];
}

class AlertMessage extends Message {
  AlertMessage(String message) : super(message, color: Styles.alertMessageTextColor);
}

class NormalMessage extends Message {
  NormalMessage(String message) : super(message);
}

class FlashMessage extends Message {
  final Duration? duration;

  FlashMessage(String message, {this.duration}) : super(message);

  show(BuildContext context) {
    late final _flush;
    _flush = Flushbar(
      message: text,
      duration: duration ?? Settings.defaultFlashMessageDuration,
      animationDuration: Duration(milliseconds: 500),
      icon: Icon(Icons.info_outline, color: Colors.blue),
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      mainButton: TextButton(
        onPressed: () => _flush.dismiss(true),
        child: Text(
          translate.core.buttons.close,
          style: TextStyle(color: Colors.lightBlueAccent),
        ),
      ),
    );
    _flush.show(context);
  }
}

typedef AnswerFunction = BoolCallback;

class QuestionMessage extends Message {
  final AnswerFunction answer;
  List<String> buttonTexts = [translate.core.buttons.no, translate.core.buttons.yes];

  QuestionMessage(String message, this.answer, color) : super(message, color: color);

  factory QuestionMessage.create(String message, answer) {
    return QuestionMessage(message, answer, Styles.normalMessageTextColor);
  }

  factory QuestionMessage.custom(String message,
      {required Button cancelButton, required Button confirmButton, int? textColor}) {
    final AnswerFunction answer =
        (bool value) async => value ? await confirmButton.callback() : await cancelButton.callback();
    return QuestionMessage(message, answer, textColor ?? Styles.normalMessageTextColor)
      ..buttonTexts = [cancelButton.text, confirmButton.text];
  }
}
