import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/core/utils/utils.dart';
import 'package:zebra_scanner/module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

String? encryptionKey;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final language = prefs.getString(LocalStorageKeys.languageKey) ?? AppLocale.cs.name;
  LocaleSettings.setLocale(AppLocale.values.byName(language));

  await SentryFlutter.init(
    (options) {
      options.dsn = Settings.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      encryptionKey = await Utils.getSecuredKey();
      runApp(MainApp());
      Sentry.configureScope(
        (scope) async => scope.setExtra("Terminal ID", await Utils.getDeviceId()),
      );
    },
  );
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(
      child: ModularApp(
        module: MainModule(),
        child: PlatformProvider(builder: (context) {
          //return _getPlatformApp(context).createMaterialWidget(context).modular();
          return _getPlatformApp(context).createCupertinoWidget(context).modular();
        }),
      ),
    );
  }

  PlatformApp _getPlatformApp(BuildContext context) {
    return PlatformApp(
      initialRoute: Routes.home,
      material: (_, __) => MaterialAppData(
        theme: ThemeData(
          appBarTheme: AppBarTheme(backgroundColor: Styles.appColor),
        ),
      ),
      cupertino: (_, __) => CupertinoAppData(
        theme: CupertinoThemeData(
          barBackgroundColor: Colors.white,
        ),
      ),
      locale: TranslationProvider.of(context).flutterLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleSettings.supportedLocales,
    );
  }
}
