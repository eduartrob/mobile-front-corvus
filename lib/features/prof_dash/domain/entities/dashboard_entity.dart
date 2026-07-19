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
}