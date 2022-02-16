import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/core/providers/http_provider.dart';
import 'package:zebra_scanner/modules/example/handover/handover_info.dart';

class HandOverRepository {
  final HttpProvider httpProvider = Modular.get<HttpProvider>();

  Future<HandOverInfo> getHandoverInfo() async {
    return Future.value(HandOverInfo(
      orderId: "473893945",
      sender: "Martin Jablečník",
      receiver: "Barbora Minářová",
      address: "Babákova 2390/2\n148 00   Praha 11 - Chodov",
      phone: "+420 620 726 811",
      deliveryType: "Express do ruky",
      date: DateTime.now(),
    ));
  }
}
