class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? token;
  final String? role;
  final String? universityId;
  final String? careerId;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.token,
    this.role,
    this.universityId,
    this.careerId,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? token,
    String? role,
    String? universityId,
    String? careerId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      token: token ?? this.token,
      role: role ?? this.role,
      universityId: universityId ?? this.universityId,
      careerId: careerId ?? this.careerId,
    );
  }
}

