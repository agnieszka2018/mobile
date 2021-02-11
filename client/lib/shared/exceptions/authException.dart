class AuthException implements Exception {
  final String msg;
  const AuthException([this.msg]);

  @override
  String toString() => msg ?? "AuthException - session expired, need to log in";
}
