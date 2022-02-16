import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/modules/app/constants.dart';
import 'package:zebra_scanner/modules/app/user_store.dart';

class AuthGuard extends RouteGuard {
  AuthGuard() : super(redirectTo: AppRoutes.auth);

  final userStore = Modular.get<UserStore>();

  @override
  Future<bool> canActivate(String path, ModularRoute router) {
    return Future.value(userStore.isLoggedIn);
  }
}