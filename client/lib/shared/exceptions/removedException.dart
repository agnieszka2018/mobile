class RemovedException implements Exception {
  final String msg;
  const RemovedException([this.msg]);

  @override
  String toString() => msg ?? "RemovedException - the item was already removed";
}
