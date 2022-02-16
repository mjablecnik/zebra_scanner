import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/core/endpoints.dart';
import 'package:zebra_scanner/core/providers/http_provider.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';

class ConnectionService {
  final HttpProvider httpProvider = Modular.get<HttpProvider>();
  String lastConnectionCheck = translate.app.info.connection.nothing;

  ConnectionService() {
    if (httpProvider.isReady) {
      checkConnection();
    } else {
      Timer(Duration(seconds: 5), () => checkConnection());
    }
    Timer.periodic(Duration(seconds: 60), (Timer t) => checkConnection());
  }

  Future<bool> checkConnection([String? apiServer]) async {
    try {
      var s = Stopwatch();
      s.start();
      var response = await httpProvider.sendGet("${apiServer ?? httpProvider.apiServer}${AppEndpoints.healthCheck}", "");
      s.stop();
      if (response.statusCode == 200) {
        var currentTime = DateTime.now().toString().split('.')[0];
        lastConnectionCheck = "$currentTime - ${s.elapsedMilliseconds}ms";
        return true;
      } else {
        lastConnectionCheck = translate.app.info.connection.nothing;
        return false;
      }
    } on Exception {
      lastConnectionCheck = translate.app.info.connection.nothing;
      return false;
    }
  }
}
