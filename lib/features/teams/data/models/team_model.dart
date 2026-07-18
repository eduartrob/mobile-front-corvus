import 'package:mobile/features/student_directory/domain/entities/student.dart';

class SocialLinkModel {
  final String platform;
  final String url;

  const SocialLinkModel({
    required this.platform,
    required this.url,
  });

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) {
    return SocialLinkModel(
      platform: json['platform']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
    };
  }
}

class TeamMemberModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role; // e.g. "LEADER", "MEMBER"

  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id']?.toString() ?? json['id_usuario']?.toString() ?? '',
      name: json['name'] ?? json['nombre'] ?? '',
      email: json['email'] ?? json['correo'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['foto'] ?? json['photoUrl'],
      role: json['role'] ?? json['rol'] ?? 'MEMBER',
    );
  }

  Student toStudent() {
    return Student(
      id: id,
      name: name,
      username: email.split('@').first,
      bio: role == 'LEADER' ? 'Líder de equipo' : 'Integrante del equipo',
      tags: [],
      avatarUrl: avatarUrl ?? '',
      isVerified: true,
    );
  }
}

class TeamModel {
  final String id;
  final String name;
  final String description;
  final List<TeamMemberModel> members;
  final List<SocialLinkModel> socialLinks;
  final Map<String, dynamic>? project;
  final int maxMembers;

  const TeamModel({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.socialLinks,
    this.project,
    this.maxMembers = 3,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    var membersList = json['members'] as List? ?? json['integrantes'] as List? ?? [];
    var linksList = json['socialLinks'] as List? ?? json['redes_sociales'] as List? ?? [];

    return TeamModel(
      id: json['id']?.toString() ?? json['id_equipo']?.toString() ?? '',
      name: json['name'] ?? json['nombre'] ?? '',
      description: json['description'] ?? json['descripcion'] ?? '',
      members: membersList.map((m) => TeamMemberModel.fromJson(m)).toList(),
      socialLinks: linksList.map((l) => SocialLinkModel.fromJson(l)).toList(),
      project: json['project'] as Map<String, dynamic>?,
      maxMembers: json['maxMembers'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'members': members.map((m) => {
        'id': m.id,
        'name': m.name,
        'email': m.email,
        'avatarUrl': m.avatarUrl,
        'role': m.role,
      }).toList(),
      'socialLinks': socialLinks.map((l) => l.toJson()).toList(),
      'project': project,
      'maxMembers': maxMembers,
    };
  }
}
