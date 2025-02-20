class User {
  final int id;
  final String name;
  final String email;
  final String requestPath; // เปลี่ยนจาก headers เป็น requestPath

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.requestPath,
  });

  factory User.fromJson(Map<String, dynamic> json, {required String path}) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      requestPath: path,
    );
  }
}
