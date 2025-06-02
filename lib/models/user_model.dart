// lib/models/user_model.dart
class User {
  final int? id;
  final String username;
  final String password; // In a real app, this would be a hashed password
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'username': username,
      'password': password, // Store hashed password in a real app
    };
    if (id != null) {
      map['id'] = id;
    }
    // 'createdAt' is handled by DEFAULT CURRENT_TIMESTAMP on insert
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      createdAt: map['createdAt'] as String?,
    );
  }
}