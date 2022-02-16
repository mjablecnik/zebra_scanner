import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/core/endpoints.dart';
import 'package:zebra_scanner/core/exceptions.dart';
import 'package:zebra_scanner/core/providers/http_provider.dart';
import 'package:zebra_scanner/modules/app/models/user_model.dart';

class AuthRepository {
  final HttpProvider httpProvider = Modular.get<HttpProvider>();

  Future<AuthorizedUser> login(userCode) async {
    try {
      final response = await httpProvider.sendGet(AuthEndpoints.user, userCode);
      return AuthorizedUser.fromJson(response.data);
    } on ServerException catch (e) {
      if (e.response?.statusCode == 403) {
        if ((e.response?.data["message"] as String).contains("Unknown device")) {
          throw UnknownDeviceException();
        }
      }
      throw ServerException(null);
    }
  }

  registerDevice(String userCode) async {
    try {
      Response<dynamic> response = await httpProvider.sendPost(AuthEndpoints.registerDevice, "", userCode);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkManager(String code) async {
    try {
      final response = await httpProvider.sendPost(AuthEndpoints.checkManager, {"code": code});
      return response.data["result"];
    } on NotFoundServerException {
      return false;
    }
  }
}
