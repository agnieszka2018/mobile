class Procedure {
  String id;
  String hash;
  String name;
  int quantity;
  bool completed;

  Procedure({
    this.id,
    this.hash,
    this.name,
    this.quantity,
    this.completed,
  });

  factory Procedure.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Procedure(
      hash: map['hash'],
      name: map['name'],
      quantity: map['quantity'],
      completed: map['completed'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hash': hash,
      'name': name,
      'quantity': quantity,
      'completed': completed == true ? 1 : 0
    };
  }

  Procedure.fromJson(Map<String, dynamic> json) {
    hash = json['hash'];
    name = json['name'];
    quantity = json['quantity'];
    completed = json['completed'];
  }

  Map<String, dynamic> toJson() => {
        "hash": hash,
        "name": name,
        "quantity": quantity,
        "completed": completed,
      };
}
