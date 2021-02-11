class CredentialsException implements Exception {
  final String msg;
  const CredentialsException([this.msg]);

  @override
  String toString() =>
      msg ?? "CredentialsException - incorrect e-mail or password";
}
