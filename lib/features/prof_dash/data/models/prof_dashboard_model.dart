class ProfDashboardAlert {
  final String icon;
  final String color;
  final String text;

  ProfDashboardAlert({
    required this.icon,
    required this.color,
    required this.text,
  });

  factory ProfDashboardAlert.fromJson(Map<String, dynamic> json) {
    return ProfDashboardAlert(
      icon: json['icon'] ?? 'info_outline',
      color: json['color'] ?? 'primary',
      text: json['text'] ?? '',
    );
  }
}

class ProfDashboardMetrics {
  final int studentsWithTeam;
  final int studentsWithoutTeam;

  ProfDashboardMetrics({
    required this.studentsWithTeam,
    required this.studentsWithoutTeam,
  });

  factory ProfDashboardMetrics.fromJson(Map<String, dynamic> json) {
    return ProfDashboardMetrics(
      studentsWithTeam: json['students_with_team'] ?? 0,
      studentsWithoutTeam: json['students_without_team'] ?? 0,
    );
  }
}

class ProfDashboardModel {
  final int totalTeams;
  final int readyProposals;
  final ProfDashboardMetrics metrics;
  final List<ProfDashboardAlert> alerts;

  ProfDashboardModel({
    required this.totalTeams,
    required this.readyProposals,
    required this.metrics,
    required this.alerts,
  });

  factory ProfDashboardModel.fromJson(Map<String, dynamic> json) {
    return ProfDashboardModel(
      totalTeams: json['total_teams'] ?? 0,
      readyProposals: json['ready_proposals'] ?? 0,
      metrics: ProfDashboardMetrics.fromJson(json['metrics'] ?? {}),
      alerts: (json['alerts'] as List?)?.map((e) => ProfDashboardAlert.fromJson(e)).toList() ?? [],
    );
  }
}
