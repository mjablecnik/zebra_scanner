import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:zebra_scanner/components/table.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/modules/barcode/barcode_models.dart';
import 'package:zebra_scanner/modules/barcode/barcode_store.dart';
import 'package:html_unescape/html_unescape.dart';

class BarcodeList extends OwnTable {
  BarcodeList({
    Key? key,
    required this.codes,
  }) : super(key: key) {
    logger.info(LogAction.data(this.codes));
  }

  final List<Barcode> codes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [for (var code in codes) ListItem(code)],
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem(
    this.item, {
    Key? key,
  }) : super(key: key);

  final Barcode item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.7),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () {
                logger.info(LogAction.press("Delete: $item"));
                Modular.get<BarcodeStore>().removeItem(item);
              },
            ),
            SizedBox(
              width: 240,
              child: Text(
                item.code,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.blue,
              ),
              onPressed: () async {
                final String? note = await prompt(
                  context,
                  title: Text(translate.barcode.note),
                  textCancel: Text(translate.core.buttons.cancel),
                  textOK: Text(translate.core.buttons.save),
                  minLines: 1,
                  maxLines: 30,
                  initialValue: HtmlUnescape().convert(item.note),
                  barrierDismissible: true,
                  validator: (String? value) {
                    const maxAmount = 1000;
                    if (value!.length > maxAmount) {
                      return translate.barcode.longTextAlert(maxAmount: maxAmount);
                    } else {
                      return null;
                    }
                  },
                );
                if (note != null) {
                  final tmpItem = Barcode(item.code, item.note);
                  item.note = const HtmlEscape().convert(note);
                  logger.info(LogAction.press("Update note from: $tmpItem, to: $item"));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
