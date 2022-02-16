import 'package:dio/dio.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';

class WrongCodeException implements Exception {}

class UnknownDeviceException implements Exception {}

class DeviceIdException implements Exception {}

class UnexpectedException implements Exception {
  final String type = "ERROR";
  String message = "";

  UnexpectedException(this.message);

  @override
  String toString() {
    return "$type: $message";
  }
}

class ApiParseException extends UnexpectedException {
  final String type = "PARSE ERROR";

  ApiParseException(String message) : super(message);
}

class ServerException implements Exception {
  final Response? response;

  ServerException(this.response);

  String toString() {
    String message = translate.core.errors.server.unexpected;
    if (response == null) {
      message = translate.core.errors.server.connection;
    } else if (response!.statusCode! == 401) {
      message = translate.core.errors.server.unauthorized;
    } else if (response!.statusCode! == 403) {
      message = translate.core.errors.server.permissionDenied;
    } else if (response!.statusCode! == 404) {
      message = translate.core.errors.server.notFound;
    } else if (response!.statusCode! >= 400 && response!.statusCode! < 500) {
      message = translate.core.errors.server.badRequest;
    } else if (response!.statusCode! >= 500) {
      message = translate.core.errors.server.internalError;
    }
    return message;
  }
}

class NotFoundServerException extends ServerException {
  NotFoundServerException(Response? response) : super(response);
}
