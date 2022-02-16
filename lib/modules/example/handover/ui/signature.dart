import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/core/utils/extensions.dart';
import 'package:zebra_scanner/core/utils/messages.dart';
import 'package:zebra_scanner/modules/example/constants.dart';

class SignatureItem extends StatefulWidget {
  const SignatureItem({
    Key? key,
  }) : super(key: key);

  @override
  State<SignatureItem> createState() => _SignatureItemState();
}

class _SignatureItemState extends State<SignatureItem> {
  Uint8List? sign;
  int turn = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (sign != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate.example.handover.labels.signature,
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                turn += 1;
              });
            },
            child: SignatureImage(sign: sign, turn: turn),
          ),
          _buildButton(
            text: translate.example.handover.buttons.save,
            onPressed: () {
              Modular.to.pop();
              FlashMessage(translate.example.handover.messages.success).show(context);
            },
          ),
          SizedBox(height: 32),
        ],
      );
    } else {
      return _buildButton(
        text: translate.example.handover.buttons.sign,
        onPressed: () async {
          final sign = await Modular.to.pushNamed(SubRoutes.signature.relative());
          if (sign != null) {
            setState(() {
              this.sign = sign as Uint8List;
            });
          }
        },
      );
    }
  }

  Center _buildButton({required VoidCallback onPressed, required String text}) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 50,
        child: CupertinoButton.filled(
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class SignatureImage extends StatelessWidget {
  const SignatureImage({
    Key? key,
    required this.sign,
    required this.turn,
  }) : super(key: key);

  final Uint8List? sign;
  final int turn;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: decodeImageFromList(sign!),
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.hasData) {
          //final image = snapshot.data!;
          //print(image.width);
          //print(image.height);
          Image signImage = Image.memory(sign!);
          //turn = image.width < image.height ? 0 : 1;
          return RotatedBox(
            quarterTurns: turn,
            child: LimitedBox(
              maxHeight: 200.0,
              maxWidth: 200.0,
              child: signImage,
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
