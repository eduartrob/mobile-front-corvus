class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? token;
  final String? role;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.token,
    this.role,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? token,
    String? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }
}
