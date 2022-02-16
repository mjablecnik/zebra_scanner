import 'package:flutter_modular/flutter_modular.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:zebra_scanner/core/utils/utils.dart';
import 'package:zebra_scanner/modules/app/constants.dart';
import 'package:zebra_scanner/modules/app/user_store.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({
    Key? key,
  }) : super(key: key);

  _getDeviceId() {
    return FutureBuilder<String>(
      future: Utils.getDeviceId(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!, style: const TextStyle(fontSize: 12));
        } else {
          return Text(translate.components.mainMenu.unknown, style: const TextStyle(fontSize: 12));
        }
      },
    );
  }

  _getVersion() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.version);
        } else {
          return Text(translate.app.info.unknown);
        }
      },
    );
  }

  Padding _buildLoggedUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(translate.components.mainMenu.loggedUser, style: TextStyle(fontSize: 14, color: Colors.black54)),
          SizedBox(height: 6),
          Text(
            Modular.get<UserStore>().currentUser.username,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  Container _buildMenuHeader() {
    return Container(
      color: Styles.appColor,
      padding: EdgeInsets.only(top: 40, left: 12, bottom: 16),
      child: Row(
        children: [
          InkWell(
            child: Icon(Icons.close, color: Colors.white, size: 24),
            onTap: () => Modular.to.pop(),
          ),
          SizedBox(width: 20),
          Text(
            translate.components.mainMenu.title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildMenuHeader(),
        SizedBox(height: 14),
        _buildLoggedUserInfo(),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text(translate.components.mainMenu.settings),
          onTap: () => Modular.to.pushNamed(AppRoutes.info),
        ),
        ListTile(
          leading: Icon(Icons.language),
          title: Text(translate.components.mainMenu.language),
          onTap: () => Utils.changeLanguage(context),
        ),
        if (Modular.get<UserStore>().isLoggedIn)
          ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text(translate.components.mainMenu.logs),
            onTap: () => Modular.to.pushNamed(AppRoutes.logs),
          )
        else
          ListTile(
            title: Text(""),
          ),
        ListTile(
          title: Text(""),
        ),
        ListTile(
          title: Text(""),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(top: 12, left: 16),
          child: Row(
            children: [
              Text(translate.components.mainMenu.version, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              SizedBox(width: 12),
              _getVersion()
            ],
          ),
        ),
        ListTile(
          onTap: () async => Modular.to.pushNamed(AppRoutes.qrCode, arguments: await Utils.getDeviceId()),
          title: Text(translate.components.mainMenu.serialNumber),
          subtitle: _getDeviceId(),
        ),
      ],
    );
  }
}
