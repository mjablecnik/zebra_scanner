import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/components/layout.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/modules/barcode/barcode_repository.dart';
import 'package:zebra_scanner/modules/barcode/barcode_models.dart';

class SelectBarcodeTypePage extends StatelessWidget {
  SelectBarcodeTypePage({Key? key}) : super(key: key) {
    logger.info(LogAction.screen(translate.barcode.selectTypeTitle));
  }

  final barcodeRepository = Modular.get<BarcodeRepository>();

  @override
  Widget build(BuildContext context) {
    return Layout(
      enableMainMenu: false,
      title: translate.barcode.selectTypeTitle,
      child: FutureBuilder(
        future: barcodeRepository.getTypes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(4.0),
              children: [
                for (var type in snapshot.data as List<BarcodeType>)
                  GestureDetector(
                    onTap: () => Modular.to.pop(type),
                    child: Padding(
                      padding: const EdgeInsets.all(3.6),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                          color: Colors.grey.shade300,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.9),
                              spreadRadius: 1,
                              blurRadius: 2.6,
                              offset: Offset(0.2, 0.2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            type.name,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
