import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zebra_scanner/core/utils/utils.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/exceptions.dart';

class HttpProvider {
  late final Dio _dio;
  late String? _userCode;

  String get apiServer => _dio.options.baseUrl;

  bool get isReady => apiServer.isNotEmpty;

  set apiServer(value) => _dio.options.baseUrl = value;

  HttpProvider() {
    _dio = Dio(BaseOptions(connectTimeout: Settings.serverConnectTimeout));
    _dio.addSentry(
      //captureFailedRequests: true,
      maxRequestBodySize: MaxRequestBodySize.always,
    );
    setupApiServer();
  }

  setClientUser(userCode) {
    this._userCode = userCode;
  }

  void deleteClientUser() {
    this._userCode = null;
  }

  Future<String> setupApiServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiServer = prefs.getString(LocalStorageKeys.apiServerKey) ?? Settings.defaultApiServer;
    return Future.value(apiServer);
  }

  updateApiServer(String apiServer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(LocalStorageKeys.apiServerKey, apiServer);
    this.apiServer = apiServer;
  }

  Future<Options> _getOptions(String? userCode) async {
    final auth = base64Encode(utf8.encode("${userCode ?? _userCode}:"));
    return Options(headers: {
      'Authorization': 'Basic ' + auth,
      'X-Device-UID': await Utils.getDeviceId(),
    });
  }

  Future<Response<dynamic>> sendGet(String url, [String? userCode]) async {
    try {
      var response = await _dio.get(
        url,
        options: await _getOptions(userCode),
      );
      return response;
    } on DioError catch (e) {
      print(e);
      if (e.response?.statusCode == 404) {
        throw NotFoundServerException(e.response);
      } else {
        throw ServerException(e.response);
      }
    }
  }

  Future<Response<dynamic>> sendPost(String url, [data, String? userCode]) async {
    try {
      var response = await _dio.post(
        url,
        data: data,
        options: await _getOptions(userCode),
      );
      return response;
    } on DioError catch (e) {
      print(e);
      if (e.response?.statusCode == 404) {
        throw NotFoundServerException(e.response);
      } else {
        throw ServerException(e.response);
      }
    }
  }

  Future<Response<dynamic>> sendPut(String url, [data, String? userCode]) async {
    try {
      var response = await _dio.put(
        url,
        data: data,
        options: await _getOptions(userCode),
      );
      return response;
    } on DioError catch (e) {
      print(e);
      if (e.response?.statusCode == 404) {
        throw NotFoundServerException(e.response);
      } else {
        throw ServerException(e.response);
      }
    }
  }

  Future<Response<dynamic>> sendDelete(String url, [data, String? userCode]) async {
    try {
      var response = await _dio.delete(
        url,
        data: data,
        options: await _getOptions(userCode),
      );
      return response;
    } on DioError catch (e) {
      print(e);
      if (e.response?.statusCode == 404) {
        throw NotFoundServerException(e.response);
      } else {
        throw ServerException(e.response);
      }
    }
  }

  Future<Response> sendFile(String url, File file) async {
    try {
      var response = await _dio.post(
        url,
        data: file.openRead(),
        options: Options(
          headers: {
            Headers.contentLengthHeader: await file.length(),
          },
        ),
      );
      return response;
    } on DioError catch (e) {
      print(e);
      if (e.response?.statusCode == 404) {
        throw NotFoundServerException(e.response);
      } else {
        throw ServerException(e.response);
      }
    }
  }
}
