import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:zebra_scanner/core/exceptions.dart';
import 'package:zebra_scanner/core/providers/http_provider.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/modules/app/auth_repository.dart';
import 'package:zebra_scanner/modules/app/constants.dart';
import 'package:zebra_scanner/modules/app/models/user_model.dart';

class UserStore extends StreamStore<Exception, User> {
  UserStore() : super(AnonymousUser());

  final HttpProvider httpProvider = Modular.get<HttpProvider>();
  final AuthRepository authRepository = Modular.get<AuthRepository>();

  loginWithCode(String userCode) async {
    if (!userCode.startsWith("ML")) {
      throw WrongCodeException();
    }

    try {
      final AuthorizedUser user = await authRepository.login(userCode);
      update(user);
      httpProvider.setClientUser(userCode);
      Modular.to.navigate(AppRoutes.home);
      logger.info(LogAction.process("Logged in as: ${user.firstName} ${user.lastName}"));
    } on UnknownDeviceException {
      update(UserWithUnknownDevice(userCode));
      rethrow;
    }
  }

  logout() {
    update(AnonymousUser());
    httpProvider.deleteClientUser();
    Modular.to.navigate(AppRoutes.auth);
    logger.info(LogAction.process("Logged out"));
  }

  registerDevice() async {
    String userCode = (this.state as UserWithUnknownDevice).userCode;
    final result = await authRepository.registerDevice(userCode);
    logger.info(LogAction.process("Sent request for device registration"));
    return result;
  }

  bool get isLoggedIn => this.currentUser.runtimeType == AuthorizedUser;

  User get currentUser => this.state;

  User? get authorizedUser => isLoggedIn ? currentUser : null;
}
