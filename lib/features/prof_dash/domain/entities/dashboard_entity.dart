/// Entidad de dominio pura para los datos del dashboard del profesor.
class DashboardEntity {
  final int totalTeams;
  final int readyProposals;
  final int studentsWithTeam;
  final int studentsWithoutTeam;
  final List<DashboardAlertEntity> alerts;

  const DashboardEntity({
    this.totalTeams = 0,
    this.readyProposals = 0,
    this.studentsWithTeam = 0,
    this.studentsWithoutTeam = 0,
    this.alerts = const [],
  });

  factory DashboardEntity.fromJson(Map<String, dynamic> json) {
    return DashboardEntity(
      totalTeams: json['totalTeams'] ?? 0,
      readyProposals: json['readyProposals'] ?? 0,
      studentsWithTeam: json['studentsWithTeam'] ?? 0,
      studentsWithoutTeam: json['studentsWithoutTeam'] ?? 0,
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => DashboardAlertEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTeams': totalTeams,
      'readyProposals': readyProposals,
      'studentsWithTeam': studentsWithTeam,
      'studentsWithoutTeam': studentsWithoutTeam,
      'alerts': alerts.map((a) => a.toJson()).toList(),
    };
  }
}

class DashboardAlertEntity {
  final String icon;
  final String color;
  final String text;

  const DashboardAlertEntity({
    this.icon = 'info_outline',
    this.color = 'primary',
    this.text = '',
  });

  factory DashboardAlertEntity.fromJson(Map<String, dynamic> json) {
    return DashboardAlertEntity(
      icon: json['icon'] ?? 'info_outline',
      color: json['color'] ?? 'primary',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'color': color,
      'text': text,
    };
  }
}