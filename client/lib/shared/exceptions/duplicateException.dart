class DuplicateException implements Exception {
  final String msg;
  const DuplicateException([this.msg]);

  @override
  String toString() =>
      msg ?? "DuplicateException - an e-mail is already registered";
}
