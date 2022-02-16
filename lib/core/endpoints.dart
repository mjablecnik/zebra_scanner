class AppEndpoints {
  static const sendLogs = "/v1/logs";
  static const healthCheck = "/v1/health";
}

class AuthEndpoints {
  static const user = "/v1/user";
  static const registerDevice = "/v1/device/register";
  static const checkManager = "/v1/user/manager/check";
}

class BarcodeEndpoints {
  static const types = "/v1/barcode/types";
  static const send = "/v1/barcode/type/%s/send";
}
