// lib/models/user_model.dart
class User {
  final int? id;
  final String username;
  final String password; // This will now be the HASHED password
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.password, // Expects a hashed password when creating from DB or for saving
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'username': username,
      'password': password, // This should be the hashed password
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String, // This will be the hashed password from DB
      createdAt: map['createdAt'] as String?,
    );
  }
}