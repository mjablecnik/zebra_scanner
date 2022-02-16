import 'package:flutter/material.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/core/utils/utils.dart';

class MenuItem extends StatelessWidget {
  final String text;
  final VoidCallback callback;
  final Color color;

  const MenuItem({
    Key? key,
    required this.text,
    required this.callback,
    this.color = Colors.lightBlue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: SizedBox(
        width: 200,
        height: 48,
        child: ElevatedButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(color)),
          onPressed: () {
            logger.info(LogAction.press(text, buttonType: ButtonType.menu));
            Utils.exceptionHandler(callback);
          },
          child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
