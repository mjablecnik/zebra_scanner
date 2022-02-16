import 'dart:async';

import 'package:flutter/material.dart' show IconButton, Icon, Icons;
import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/models.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/core/utils/extensions.dart';
import 'package:zebra_scanner/core/utils/utils.dart';
import 'package:zebra_scanner/components/scan_code/scan_code_store.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';
import 'package:zebra_scanner/modules/barcode/barcode_models.dart';
import 'package:zebra_scanner/modules/barcode/barcode_repository.dart';
import 'package:zebra_scanner/modules/barcode/constants.dart';
import 'package:zebra_scanner/modules/barcode/widgets/barcode_list.dart';

class BarcodeState {
  BarcodeType? type;
  final List<Barcode> barcodeList = [];
}

class BarcodeStore extends ScanCodeStore {
  BarcodeStore() : super() {
    Utils.exceptionHandler(selectBarcodeType);
  }

  final BarcodeRepository barcodeRepository = Modular.get<BarcodeRepository>();
  final BarcodeState _state = BarcodeState();

  selectBarcodeType() async {
    BarcodeType? type = await Modular.to.pushNamed(SubRoutes.selectType.relative()) as BarcodeType?;
    logger.info(LogAction.select(type?.name));

    if (type == null && _state.type == null) {
      await this.finishProcess();
    } else {
      if (type != null) {
        _state.type = type;
        updateState();
      }
    }
  }

  updateState() async {
    nextScan(
      title: _state.type?.name,
      message: translate.barcode.scan,
      callback: (code) async {
        addItem(Barcode(code));
      },
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => selectBarcodeType(),
        ),
      ],
      specialButton: Button(translate.core.buttons.back, () {
        if (_state.barcodeList.isNotEmpty) {
          askAlertQuestion(
            message: translate.barcode.alert,
            confirmButton: Button.yes(finishProcess),
          );
        } else {
          this.finishProcess();
        }
      }),
      table: BarcodeList(codes: _state.barcodeList),
      largeButton: _state.barcodeList.isEmpty ? null : Button(translate.barcode.sendButton, sendCodes),
    );
  }

  sendCodes() async {
    final success = await barcodeRepository.registerCodes(_state.type!, _state.barcodeList);
    if (success) {
      await resetState();
      await updateState();
      selectBarcodeType();
      Timer(Duration(milliseconds: 300), () => showFlashMessage(translate.barcode.sendSuccess));
    } else {
      showAlert(translate.barcode.sendError);
    }
  }

  addItem(Barcode item) {
    final index = _state.barcodeList.indexWhere((element) => element.code == item.code);
    if (index == -1) {
      _state.barcodeList.add(item);
      updateState();
    }
  }

  removeItem(Barcode item) {
    _state.barcodeList.remove(item);
    updateState();
  }

  resetState() async {
    _state.barcodeList.clear();
    _state.type = null;
  }

  finishProcess() async {
    await resetState();
    Modular.to.pushReplacementNamed(Routes.home);
  }
}
