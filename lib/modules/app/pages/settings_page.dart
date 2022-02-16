import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:zebra_scanner/components/layout.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/providers/http_provider.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:zebra_scanner/core/services/connection_service.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/core/utils/utils.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final HttpProvider httpProvider = Modular.get<HttpProvider>();
  final ConnectionService connectionService = Modular.get<ConnectionService>();

  _getIpAddress() {
    final info = NetworkInfo();
    return FutureBuilder<String?>(
      future: info.getWifiIP(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!);
        } else {
          return Center(child: Text(translate.app.info.unknown));
        }
      },
    );
  }

  changeServerAddress(BuildContext context, String address) async {
    final loader = MyDialog.of(context).loading(translate.app.server.checkConnection, time: 10);
    final canConnect = await connectionService.checkConnection(address);
    loader.remove();
    if (canConnect) {
      httpProvider.updateApiServer(address);
      MyDialog.of(context).snack(translate.app.server.addressSaved);
    } else {
      Utils.showAlertDialog(context, translate.app.alerts.serverConnection);
    }
  }

  _getConnectivity() {
    final connectivity = Connectivity();
    return FutureBuilder<ConnectivityResult>(
      future: connectivity.checkConnectivity(),
      builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot) {
        String connected = translate.app.info.connection.notConnected;
        if (snapshot.data == ConnectivityResult.mobile) {
          connected = translate.app.info.connection.mobileData;
        } else if (snapshot.data == ConnectivityResult.wifi) {
          connected = translate.app.info.connection.wifi;
        }
        if (snapshot.hasData) {
          return Text(connected);
        } else {
          return Center(child: Text(translate.app.info.unknown));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const tilePadding = EdgeInsets.only(left: 24);
    const listViewPadding = EdgeInsets.only(top: 16);

    return Layout(
      title: translate.app.info.title,
      enableMainMenu: false,
      actions: [],
      child: ListView(
        padding: listViewPadding,
        children: [
          SectionTitle(text: translate.app.info.connection.title),
          ListTile(
            contentPadding: tilePadding,
            title: _getConnectivity(),
            subtitle: Text(translate.app.info.connection.type),
          ),
          ListTile(
            contentPadding: tilePadding,
            title: _getIpAddress(),
            subtitle: Text(translate.app.info.connection.address),
          ),
          ListTile(
            contentPadding: tilePadding,
            title: Text(httpProvider.apiServer),
            subtitle: Text(translate.app.info.connection.apiAddress),
            onTap: () async {
              logger.info(LogAction.dialog(translate.app.server.changeAddress));
              String? address = await prompt(
                context,
                title: Text(translate.app.server.changeAddress),
                initialValue: httpProvider.apiServer,
                textCancel: Text(translate.core.buttons.cancel),
                barrierDismissible: true,
              );
              logger.info(LogAction.input(address));
              if (address != null) {
                changeServerAddress(context, address);
              }
            },
          ),
          ListTile(
            contentPadding: tilePadding,
            title: Text(connectionService.lastConnectionCheck),
            subtitle: Text(translate.app.info.connection.apiCheck),
          ),
          SectionTitle(text: translate.app.info.language.title),
          ListTile(
            contentPadding: tilePadding,
            title: Text(translate.core.changeLanguage.languages[LocaleSettings.currentLocale.name]!),
            subtitle: Text(translate.app.info.language.subtitle),
            onTap: () => Utils.changeLanguage(context),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Styles.appColor, fontWeight: FontWeight.bold);
    const sectionTitlePadding = EdgeInsets.only(left: 16, top: 16);

    return Padding(
      padding: sectionTitlePadding,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
