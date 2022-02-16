import 'dart:async';
import 'dart:io';
import 'package:my_logger/core/constants.dart';
import 'package:my_logger/logger.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/endpoints.dart';
import 'package:zebra_scanner/core/providers/http_provider.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/core/utils/extensions.dart';

class LogSenderService {

  LogSenderService() {
    _setupFirstLog().then((_) {
      if (Settings.sendLogsToServer) {
        _sendToServer();
        Timer.periodic(Duration(minutes: 1), (Timer t) => _sendToServer());
        print("Sending logs to server is enabled.");
      } else {
        print("Sending logs to server is disabled.");
      }
    });
  }

  late DateTime? _firstLogDateTime;

  Stream<LogFilter> filterGenerator({required DateTime from, required DateTime to}) async* {
    var startLogTime = from;
    var endLogTime = to;
    while (startLogTime.millisecondsSinceEpoch < endLogTime.millisecondsSinceEpoch) {
      final tmpLogTime = startLogTime.add(Settings.sendLogsToServerDuration);
      yield LogFilter(startDateTime: startLogTime, endDateTime: tmpLogTime);
      startLogTime = tmpLogTime;
    }
  }

  _sendToServer() async {
    final startTime = (await _getFirstLog()).roundToHour();
    final endTime = DateTime.now().roundToHour();

    filterGenerator(from: startTime, to: endTime).forEach((filter) async {
      final logs = await MyLogger.logs.getByFilter(filter);
      if (logs.isNotEmpty) {
        switch (Settings.sendLogsType) {
          case SendLogsType.json:
            _sendLogsAsJson(logs, filter);
            break;
          case SendLogsType.file:
            _sendLogsAsFile(filter);
            break;
        }
      }
    });
  }

  _sendLogsAsJson(List<Log> logs, LogFilter filter) async {
    final transformedLogs = logs
        .map(
          (log) => {
            "message": log.text,
            "timestamp": log.timestamp,
            "time_in_milliseconds": log.timeInMillis,
            "data_log_type": log.dataLogType.toString().split('.').last,
            "log_level": log.logLevel.toString().split('.').last,
          },
        )
        .toList();

    try {
      await Modular.get<HttpProvider>().sendPost(AppEndpoints.sendLogs, {"logs": transformedLogs}, "");
      await _clearOldLogs(filter, null);
    } catch (e) {
      logger.error("Cannot send logs.");
    }
  }

  _sendLogsAsFile(LogFilter filter) async {
    var fileExport = await MyLogger.logs.export(
      fileName: "export-${filter.startDateTime!.toIso8601String()}-${filter.endDateTime!.toIso8601String()}",
      exportType: FileType.TXT,
      filter: filter,
    );

    try {
      await Modular.get<HttpProvider>().sendFile(AppEndpoints.sendLogs, fileExport);
      await _clearOldLogs(filter, fileExport);
    } catch (e) {
      logger.error("Cannot send logs.");
    }
  }

  _clearOldLogs(LogFilter filter, File? fileExport) {
    if (Settings.keepOldLogs) {
      _setFirstLog(filter.endDateTime!);
      return;
    } else {
      try {
        MyLogger.logs.deleteByFilter(filter);
        _setFirstLog(filter.endDateTime!);
        fileExport?.delete();
      } catch (e) {
        logger.error("Cannot delete old logs.");
        logger.log(LogLevel.TRACE, e);
      }
    }
  }

  _setupFirstLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? value = prefs.get(LocalStorageKeys.firstLogDateTimeKey) as int?;

    if (value == null) {
      _firstLogDateTime = DateTime.now();
      _setFirstLog(_firstLogDateTime!);
    } else {
      _firstLogDateTime = DateTime.fromMillisecondsSinceEpoch(value);
    }
  }

  Future<DateTime> _getFirstLog() async {
    if (_firstLogDateTime == null) await _setupFirstLog();
    return Future.value(_firstLogDateTime);
  }

  Future<bool> _setFirstLog(DateTime value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(LocalStorageKeys.firstLogDateTimeKey, value.millisecondsSinceEpoch);
  }
}
