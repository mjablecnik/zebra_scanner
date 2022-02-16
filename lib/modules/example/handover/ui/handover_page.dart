import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/modules/example/handover/handover_info.dart';
import 'package:zebra_scanner/modules/example/handover/handover_repository.dart';
import 'package:zebra_scanner/modules/example/handover/ui/signature.dart';

class HandOverPage extends StatelessWidget {
  HandOverPage({Key? key}) : super(key: key);

  final handoverRepository = Modular.get<HandOverRepository>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(translate.example.handover.title),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
        child: FutureBuilder(
            future: handoverRepository.getHandoverInfo(),
            builder: (BuildContext context, AsyncSnapshot<HandOverInfo> snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: [
                    Item(label: translate.example.handover.labels.orderId, value: snapshot.data!.orderId),
                    Item(label: translate.example.handover.labels.sender, value: snapshot.data!.sender),
                    Item(label: translate.example.handover.labels.receiver, value: snapshot.data!.receiver),
                    Item(label: translate.example.handover.labels.address, value: snapshot.data!.address),
                    Item(label: translate.example.handover.labels.phone, value: snapshot.data!.phone),
                    Item(label: translate.example.handover.labels.deliveryType, value: snapshot.data!.deliveryType),
                    Item(
                      label: translate.example.handover.labels.date,
                      value: snapshot.data!.date.toString().split('.')[0],
                    ),
                    SizedBox(height: 16),
                    SignatureItem(),
                  ],
                );
              } else {
                return Center(child: Text(translate.app.info.unknown));
              }
            }),
      ),
    );
  }
}

class Item extends StatelessWidget {
  const Item({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
