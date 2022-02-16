import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_test/modular_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zebra_scanner/core/models.dart';
import 'package:zebra_scanner/core/services/data_wedge_service.dart';
import 'package:zebra_scanner/components/scan_code/scan_code_page.dart';
import 'package:zebra_scanner/components/scan_code/scan_code_store.dart';
import 'package:zebra_scanner/core/utils/messages.dart';
import 'package:zebra_scanner/components/layout.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/module.dart';

var basicStore = ScanCodeStore(state: basicState);

var basicState = ScanCodeState.onlyScan(
  message: "Init message",
  callback: (String code) {
    basicStore.setError(AlertMessage(code + "123"));
    basicStore.nextScan(
      message: "Next message",
      callback: (code) => basicStore.setError(AlertMessage(code + "456")),
    );
  },
);

var nextStore = ScanCodeStore(state: nextState);

var nextState = ScanCodeState.onlyScan(
  message: "Init message",
  callback: (String code) {
    nextStore.setError(AlertMessage(code + "123"));
    nextStore.nextScan(
      message: "Next message",
      callback: (code) => nextStore.setError(AlertMessage(code + "456")),
    );
  },
);

var buttonStore = ScanCodeStore(state: buttonState);

var buttonState = ScanCodeState.onlyScan(
  message: "Init message",
  callback: (String code) {
    buttonStore.setError(AlertMessage(code + "123"));
  },
  thirdButton: Button("Back", () => buttonStore.setError(AlertMessage("Going to back.."))),
);

var nextStoreWithButton = ScanCodeStore(state: nextStateWithButton);

var nextStateWithButton = ScanCodeState.onlyScan(
  message: "Init message",
  callback: (String code) {
    nextStoreWithButton.setError(AlertMessage(code + "123"));
    nextStoreWithButton.nextScan(
      message: "Next message",
      callback: (code) => nextStoreWithButton.setError(AlertMessage(code + "456")),
      largeButton: Button("Back", () => nextStoreWithButton.setError(AlertMessage("Going to back.."))),
    );
  },
);

createScanCodeScreen(ScanCodeStore store) {
  return MaterialApp(
    home: Layout(
      child: ScanCodePage(store: store),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});

    initModule(MainModule(), replaceBinds: [
      Bind.singleton<DataWedgeService>((i) => DataWedgeService()),
    ]);
  });

  group('Scan code screen tests', () {
    testWidgets('Init Message should be visible', (tester) async {
      await tester.pumpWidget(createScanCodeScreen(basicStore));
      expect(find.text("Init message"), findsOneWidget);
    });

    testWidgets('Check buttons', (tester) async {
      await tester.pumpWidget(createScanCodeScreen(basicStore));

      expect(find.text(translate.components.scanCode.buttons.scan), findsOneWidget);
      expect(find.text(translate.components.scanCode.buttons.input), findsOneWidget);
    });

    testWidgets('Check input', (tester) async {
      await tester.pumpWidget(createScanCodeScreen(basicStore));
      await tester.tap(find.text(translate.components.scanCode.buttons.input));
      await tester.pumpAndSettle(Duration(seconds: 1));

      expect(find.text(translate.components.scanCode.inputDialogMessage), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text(translate.core.buttons.cancel), findsOneWidget);
    });

    testWidgets('Change screen', (tester) async {
      await tester.pumpWidget(createScanCodeScreen(nextStore));
      await tester.tap(find.text(translate.components.scanCode.buttons.input));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Input code in first screen
      await tester.enterText(find.byType(TextField), "test");
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Check response of first screen
      expect(find.text('test123'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Check message of second screen
      expect(find.text('Next message'), findsOneWidget);
      await tester.tap(find.text(translate.components.scanCode.buttons.input));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Input code in second screen
      await tester.enterText(find.byType(TextField), "test");
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Check response of second screen
      expect(find.text('test456'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle(Duration(seconds: 1));
    });

    testWidgets('Third button', (tester) async {
      await tester.pumpWidget(createScanCodeScreen(buttonStore));
      expect(find.text('Back'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text("Going to back.."), findsOneWidget);
    });

    testWidgets('Change screen and tap third button', (tester) async {
      await tester.pumpWidget(createScanCodeScreen(nextStoreWithButton));
      await tester.tap(find.text(translate.components.scanCode.buttons.input));
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Back'), findsNothing);

      // Input code in first screen
      await tester.enterText(find.byType(TextField), "test");
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Check response of first screen
      expect(find.text('test123'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Check message of second screen
      expect(find.text('Next message'), findsOneWidget);
      await tester.tap(find.text(translate.components.scanCode.buttons.input));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Input code in second screen
      await tester.enterText(find.byType(TextField), "test");
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Check response of second screen
      expect(find.text('test456'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Ok'), findsNothing);

      // Check third button
      expect(find.text('Back'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text("Going to back.."), findsOneWidget);
    });
  });
}
