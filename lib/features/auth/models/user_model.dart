class User {
  final int? id;
  final String fullName;
  final String username;
  final String email;
  final String password;

  User({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      fullName: map['fullName'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
    );
  }

  User copyWith({
    int? id,
    String? fullName,
    String? username,
    String? email,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
