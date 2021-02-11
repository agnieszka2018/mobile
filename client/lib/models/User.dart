class User {
  final String name;
  final String email;
  final String specialization;
  User({
    this.name,
    this.email,
    this.specialization,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'specialization': specialization,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return User(
      name: map['name'],
      email: map['email'],
      specialization: map['specialization'],
    );
  }
}
