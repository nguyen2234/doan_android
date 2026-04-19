class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? avatar;
  final String? createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.avatar,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'avatar': avatar,
      'created_at': createdAt,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        password: map['password'],
        avatar: map['avatar'],
        createdAt: map['created_at'],
      );

  User copyWith({String? name, String? password, String? avatar}) => User(
        id: id,
        name: name ?? this.name,
        email: email,
        password: password ?? this.password,
        avatar: avatar ?? this.avatar,
        createdAt: createdAt,
      );
}
