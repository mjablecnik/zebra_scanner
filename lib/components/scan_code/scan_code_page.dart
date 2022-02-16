import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/models/suggestion.dart';
import 'package:zebra_scanner/core/services/data_wedge_service.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:zebra_scanner/core/models.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/core/utils/handlers.dart';
import 'package:zebra_scanner/core/utils/utils.dart';
import 'package:zebra_scanner/components/layout.dart';
import 'package:zebra_scanner/components/scan_code/scan_code_store.dart';

class ScanCodePage extends StatefulWidget {
  ScanCodePage({Key? key, required this.store}) : super(key: key);

  final ScanCodeStore store;

  @override
  _ScanCodePageState createState() => _ScanCodePageState();
}

abstract class ScanCodePageState extends State<ScanCodePage> {
  late final ScanCodeStore store;
}

class _ScanCodePageState extends ScanCodePageState with Handlers {
  final inputController = TextEditingController();
  final DataWedgeService dataWedgeService = Modular.get<DataWedgeService>();

  @override
  initState() {
    super.initState();
    store = widget.store;
    initMessageHandler();
    setupScanner();
  }

  @override
  void dispose() {
    super.dispose();
  }

  backAction() {
    logger.info(LogAction.press("Back", buttonType: ButtonType.hardware));
    if (Modular.to.canPop()) {
      Modular.to.pop();
      logger.info(LogAction.goBack("Through pop()"));
    } else if (store.state.backButtonEnabled == true) {
      logger.info(LogAction.goBack("Into previous state"));
      store.undo();
    } else if (store.state.leftButton?.text == translate.core.buttons.back) {
      logger.info(LogAction.goBack("By back button"));
      store.state.leftButton?.callback();
    } else if (store.state.quitAppEnabled == true) {
      store.askAlertQuestion(
        message: translate.app.alerts.quitAppQuestion,
        confirmButton: Button.yes(SystemNavigator.pop),
      );
    }
  }

  setupScanner() {
    dataWedgeService.scannerSetup(
      profileName: "WMS",
      onEvent: (e) async {
        exceptionHandler(() async {
          if (store.state.scanCallback != null) {
            final String? code = jsonDecode(e)['scanData'];
            logger.info(LogAction.code(code, inputType: InputCodeType.scanner));
            if (code != null) {
              await store.state.scanCallback!(code);
            }
          }
        });
      },
      onError: (e) {
        Utils.showAlertDialog(context, translate.components.scanCode.error);
      },
    );
  }

  Future<void> inputCode(BuildContext context, callback) async {
    String? code = await prompt(
      context,
      title: Text(translate.components.scanCode.inputDialogMessage),
      textCancel: Text(translate.core.buttons.cancel),
      barrierDismissible: true,
    );

    logger.info(LogAction.code(code, inputType: InputCodeType.textInput));
    if (code != null) {
      exceptionHandler(() async {
        await callback(code);
      });
    }
  }

  Future<void> scanCode(BuildContext context, callback) async {
    final String code;
    try {
      logger.info("Start camera scanning");
      code = await FlutterBarcodeScanner.scanBarcode(
        Styles.scannerColor,
        translate.components.scanCode.cancel,
        false,
        ScanMode.BARCODE,
      );
      logger.info(LogAction.code(code, inputType: InputCodeType.scanner));
      if (code != '-1') {
        store.setLoading(true);
        await callback(code);
        store.setLoading(false);
      }
    } on Exception catch (e) {
      Utils.showAlertDialog(context, e.toString());
    } catch (e) {
      Utils.showAlertDialog(context, translate.components.scanCode.error);
    } finally {
      store.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedBuilder(
      store: widget.store,
      onState: (context, ScanCodeState state) {
        return Layout(
          title: state.title,
          actions: state.actions,
          backAction: backAction,
          enableMainMenu: true,
          footer: Column(children: [
            if (state.largeButton != null)
              OwnButton(
                text: state.largeButton!.text,
                size: Utils.computeButtonSize(context, numberOfButtonsInRow: 1),
                color: Styles.largeButtonColor,
                onPressed: () => exceptionHandler(state.largeButton!.callback),
              ),
            const SizedBox(height: 8),
            if (state.type == InputType.SCAN)
              buildScanButtons(context, state)
            else if (state.type == InputType.OWN_BUTTONS)
              buildOwnButtons(context, state)
            else if (state.type == InputType.NUMBER_INPUT)
              buildInputText(context, state, TextInputType.number)
            else if (state.type == InputType.TEXT_INPUT)
              buildInputText(context, state, TextInputType.text)
            else if (state.type == InputType.TEXT_INPUT_WITH_AUTO_COMPLETE)
              buildInputTextWithAutoComplete(context, state),
            const SizedBox(height: 8),
          ]),
          backButton: () {
            if (state.backButtonEnabled == true)
              return IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  logger.info(LogAction.goBack("Into previous state"));
                  store.undo();
                },
              );
          }(),
          child: () {
            if (state.table != null)
              return buildTable(state);
            else
              return SingleChildScrollView(
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      buildMessageText(state),
                    ],
                  ),
                ),
              );
          }(),
        );
      },
    );
  }

  Column buildTable(ScanCodeState state) {
    return Column(
      children: [
        SizedBox(height: 35),
        buildMessageText(state),
        SizedBox(height: 20),
        Flexible(child: state.table!),
      ],
    );
  }

  Text buildMessageText(ScanCodeState state) {
    return Text(
      state.message.toString(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: state.color,
      ),
    );
  }

  dynamic buildInputTextWithAutoComplete(BuildContext context, ScanCodeState state) {
    return Center(
      child: Column(
        children: [
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              autofocus: true,
              controller: inputController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                constraints: BoxConstraints(maxHeight: 52, maxWidth: 250),
              ),
              onSubmitted: (text) {
                inputController.text = text;
              },
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            suggestionsCallback: state.suggestionListCallback!,
            itemBuilder: (context, Suggestion suggestion) {
              return ListTile(
                title: Text(suggestion.text),
              );
            },
            hideSuggestionsOnKeyboardHide: false,
            direction: AxisDirection.up,
            hideOnEmpty: true,
            onSuggestionSelected: (Suggestion suggestion) {
              inputController.text = suggestion.text;
            },
          ),
          const SizedBox(height: 32),
          buildSubmitButton(state, context),
        ],
      ),
    );
  }

  dynamic buildInputText(BuildContext context, ScanCodeState state, TextInputType type) {
    return Center(
      child: Column(
        children: [
          TextField(
            autofocus: true,
            controller: inputController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              constraints: BoxConstraints(maxHeight: 52, maxWidth: 250),
            ),
            onSubmitted: (text) async {
              inputController.clear();
              exceptionHandler(() async {
                logger.info(LogAction.input(text));
                await state.rightButton!.callback(text);
              });
            },
            keyboardType: type,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
          const SizedBox(height: 32),
          buildSubmitButton(state, context),
        ],
      ),
    );
  }

  OwnButton buildSubmitButton(ScanCodeState state, BuildContext context) {
    return OwnButton(
      text: state.rightButton!.text,
      size: Utils.computeButtonSize(context, numberOfButtonsInRow: 2),
      color: Colors.green,
      onPressed: () async {
        final text = inputController.text;
        inputController.clear();
        exceptionHandler(() async {
          logger.info(LogAction.input(text));
          await state.rightButton!.callback(text);
        });
      },
    );
  }

  Row buildOwnButtons(BuildContext context, ScanCodeState state) {
    final size = Utils.computeButtonSize(context, numberOfButtonsInRow: 2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.leftButton != null)
          OwnButton(
            text: state.leftButton!.text,
            size: size,
            color: Styles.leftButtonColor,
            onPressed: () => exceptionHandler(state.leftButton!.callback),
          ),
        if (state.leftButton != null) const SizedBox(width: 8),
        if (state.middleButton != null)
          OwnButton(
            text: state.middleButton!.text,
            size: size,
            color: Styles.middleButtonColor,
            onPressed: () => exceptionHandler(state.middleButton!.callback),
          ),
        if (state.middleButton != null) const SizedBox(width: 8),
        if (state.rightButton != null)
          OwnButton(
            text: state.rightButton!.text,
            size: size,
            color: Styles.rightButtonColor,
            onPressed: () => exceptionHandler(state.rightButton!.callback),
          ),
      ],
    );
  }

  Row buildScanButtons(BuildContext context, ScanCodeState state) {
    final size = Utils.computeButtonSize(context, numberOfButtonsInRow: state.leftButton == null ? 2 : 3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.leftButton != null)
          OwnButton(
            text: state.leftButton!.text,
            size: size,
            color: Styles.leftButtonColor,
            onPressed: () => exceptionHandler(state.leftButton!.callback),
          ),
        if (state.leftButton != null) const SizedBox(width: 8),
        if (state.middleButton != null)
          OwnButton(
            text: state.middleButton!.text,
            size: size,
            color: Styles.middleButtonColor,
            onPressed: () async {
              await inputCode(context, state.middleButton!.callback);
            },
          ),
        if (state.middleButton != null) const SizedBox(width: 8),
        if (state.rightButton != null)
          OwnButton(
            text: state.rightButton!.text,
            size: size,
            color: Styles.rightButtonColor,
            onPressed: () async {
              await scanCode(context, state.rightButton!.callback);
            },
          ),
      ],
    );
  }
}

class OwnButton extends StatelessWidget {
  const OwnButton({
    Key? key,
    required this.text,
    required this.size,
    required this.onPressed,
    this.color = Colors.blue,
  }) : super(key: key);

  final String text;
  final Size size;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ElevatedButton(
        child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(color)),
        onPressed: () {
          logger.info(LogAction.press(text));
          this.onPressed();
        },
      ),
    );
  }
}
