import 'dart:convert';

import 'package:flutter/services.dart';

class DataWedgeService {
  static const MethodChannel _methodChannel = MethodChannel('com.darryncampbell.datawedgeflutter/command');
  static const EventChannel _scanChannel = EventChannel('com.darryncampbell.datawedgeflutter/scan');

  Future<void> sendCommand(String command, String parameter) async {
    try {
      String argumentAsJson = jsonEncode({"command": command, "parameter": parameter});

      await _methodChannel.invokeMethod('sendDataWedgeCommandStringParameter', argumentAsJson);
    } on PlatformException {
      //  Error invoking Android method
    }
  }

  _channelListen(onEvent, onError) {
    _scanChannel.receiveBroadcastStream().listen(onEvent, onError: onError);
  }

  Future<void> _createProfile(String profileName) async {
    try {
      await _methodChannel.invokeMethod('createDataWedgeProfile', profileName);
    } on PlatformException {
      //  Error invoking Android method
    }
  }

  scannerSetup({onEvent, onError, profileName}) {
    _createProfile(profileName);
    _channelListen(onEvent, onError);
  }
}
