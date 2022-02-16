import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:zebra_scanner/components/layout.dart';

class QrCodePage extends StatelessWidget {
  QrCodePage({required this.text, Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: "QR Code",
      enableMainMenu: false,
      actions: [],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImage(
              data: this.text,
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
            SizedBox(height: 16),
            Text(this.text)
          ],
        ),
      ),
    );
  }
}
