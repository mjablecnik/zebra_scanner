import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';

class SignaturePage extends StatelessWidget {
  SignaturePage({Key? key}) : super(key: key);

  final sign = GlobalKey<SignatureState>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(translate.example.handover.signatureTitle),
        trailing: TextButton(
          onPressed: () async {
            final signState = sign.currentState;
            if (signState != null && signState.hasPoints) {
              //final x = <double>[];
              //final y = <double>[];
              //for (var p in signState.points) {
              //  if (p?.dx != null) x.add(p!.dx);
              //  if (p?.dy != null) y.add(p!.dy);
              //}
              final uiImage = await signState.getData();
              final byteDataImage = await uiImage.toByteData(format: ui.ImageByteFormat.png);
              final imageBytes = byteDataImage!.buffer.asUint8List();

              Modular.to.pop(imageBytes);
            }
          },
          child: Text(translate.example.handover.buttons.save),
        ),
      ),
      child: Signature(
        color: CupertinoColors.black,
        strokeWidth: 5.0,
        backgroundPainter: null,
        onSign: null,
        key: sign,
      ),
    );
  }
}
