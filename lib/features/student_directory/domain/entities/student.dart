class Student {
  final String? id;
  final String name;
  final String username;
  final String bio;
  final List<String> tags;
  final String avatarUrl;
  final bool isVerified;
  final bool hasTeam;

  const Student({
    this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.tags,
    required this.avatarUrl,
    this.isVerified = true,
    this.hasTeam = false,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? json['studentId']?.toString() ?? json['id_usuario']?.toString(),
      name: json['name'] ?? json['nombre'] ?? '',
      username: json['username'] ?? json['usuario'] ?? '',
      bio: json['bio'] ?? json['biografia'] ?? '',
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : json['habilidades'] != null 
              ? List<String>.from(json['habilidades'])
              : [],
      avatarUrl: json['avatarUrl'] ?? json['foto'] ?? '',
      isVerified: json['isVerified'] ?? json['verificado'] ?? false,
      hasTeam: json['hasTeam'] ?? false,
    );
  }
}
