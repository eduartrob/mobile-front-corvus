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
}
