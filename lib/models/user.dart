class User {
  final String id;
  final String email;
  final bool isActive;

  User({required this.id, required this.email, required this.isActive});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      isActive: json['is_active'],
    );
  }
}
