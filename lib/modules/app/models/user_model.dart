import 'package:equatable/equatable.dart';

abstract class User {
  late final String username;
  late final String? userCode;
}

class AnonymousUser extends User {
  final String username = "Anonymous";
  final String? userCode = null;
}

class UserWithUnknownDevice extends User {
  final String username = "Anonymous";
  final String userCode;

  UserWithUnknownDevice(this.userCode);
}

class AuthorizedUser extends User with EquatableMixin {
  final int id;
  final String userCode;
  final String firstName;
  final String lastName;

  AuthorizedUser({required this.id, required this.userCode, required this.firstName, required this.lastName});

  @override
  List<Object> get props => [id, firstName, lastName];

  @override
  bool get stringify => true;

  String get username => "$firstName $lastName";

  factory AuthorizedUser.fromJson(json) {
    return AuthorizedUser(
      id: json["id"] as int,
      userCode: json["username"] as String,
      firstName: json["firstName"] as String,
      lastName: json["lastName"] as String,
    );
  }
}
