import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/corvus_metric_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/prof_dash/presentation/provider/prof_dash_provider.dart';
import 'package:mobile/features/prof_dash/presentation/pages/prof_directory_page.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/shared/widgets/corvus_skeleton.dart';

class ProfDashPage extends StatefulWidget {
  final String projectId;
  final VoidCallback? onSwitchToReviews;
  
  const ProfDashPage({
    super.key, 
    required this.projectId,
    this.onSwitchToReviews,
  });

  @override
  State<ProfDashPage> createState() => _ProfDashPageState();
}

class _ProfDashPageState extends State<ProfDashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfDashboardProvider>().loadDashboardStats(projectId: widget.projectId);
    });
  }

  void _showUpcomingFeature(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureUpcoming),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CorvusTopBar(
        extraActions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/prof-project/${widget.projectId}/config');
            },
          ),
        ],
      ),
      body: Consumer<ProfDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.errorMessage != null && provider.dashboardData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!, style: TextStyle(color: colorScheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadDashboardStats(projectId: widget.projectId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final data = provider.dashboardData;
          final bool isLoading = provider.isLoading && data == null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<ProjectProvider>(
                  builder: (context, projProv, child) {
                    final project = projProv.myProjects.firstWhere(
                      (p) => p['id'] == widget.projectId, 
                      orElse: () => null,
                    );
                    if (project == null) return const SizedBox.shrink();
                    
                    final pastelColors = const [
                      Color(0xFF5C88DA), // Muted Blue
                      Color(0xFF9A73C9), // Muted Purple
                      Color(0xFF56A98A), // Muted Green
                      Color(0xFFD98A53), // Muted Orange
                      Color(0xFFD67389), // Muted Pink
                    ];
                    
                    Color bgColor;
                    if (project['theme_color'] != null) {
                      final colorStr = project['theme_color'].toString().replaceAll('#', '0xFF');
                      bgColor = Color(int.parse(colorStr));
                    } else {
                      bgColor = pastelColors[project['id'].hashCode.abs() % pastelColors.length];
                    }
                    
                    final String? patternName = project['theme_pattern'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            if (patternName != null)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SvgPicture.asset(
                                    'assets/patterns/$patternName.svg',
                                    fit: BoxFit.none,
                                    colorFilter: ColorFilter.mode(
                                      ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : Colors.grey.shade700.withValues(alpha: 0.2),
                                      BlendMode.srcATop,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.class_, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      project['name'],
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: CorvusMetricCard(
                        label: 'EQUIPOS FORMADOS',
                        value: isLoading ? '' : '${data?.totalTeams}',
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CorvusMetricCard(
                        label: 'PROPUESTAS LISTAS',
                        value: isLoading ? '' : '${data?.readyProposals} de ${data?.totalTeams} equipos',
                        icon: Icons.description_outlined,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tarjeta de Atención Requerida
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.notifications_active_outlined,
                                size: 18, color: colorScheme.tertiary),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Atención Requerida',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        const CorvusSkeleton(height: 80, width: double.infinity)
                      else if (data!.alerts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryFixedDim.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 20, color: colorScheme.secondaryFixed),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Todo al día. No hay elementos que requieran atención inmediata.',
                                  style: TextStyle(
                                    color: colorScheme.onSecondaryFixedVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...data.alerts.map((alert) {
                          IconData iconData = Icons.info_outline;
                          if (alert.icon == 'error_outline') iconData = Icons.error_outline;
                          if (alert.icon == 'warning_amber') iconData = Icons.warning_amber;

                          Color bgColor = colorScheme.primaryContainer;
                          Color fgColor = colorScheme.primary;
                          if (alert.color == 'error') {
                            bgColor = colorScheme.errorContainer;
                            fgColor = colorScheme.error;
                          } else if (alert.color == 'warning') {
                            bgColor = colorScheme.tertiaryContainer;
                            fgColor = colorScheme.tertiary;
                          } else {
                            bgColor = colorScheme.secondaryFixedDim;
                            fgColor = colorScheme.secondaryFixed;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bgColor.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(iconData, size: 20, color: fgColor),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      alert.text,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (widget.onSwitchToReviews != null) {
                              widget.onSwitchToReviews!();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.viewReports,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tarjeta de Métricas Rápidas
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryFixedDim,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.insights_outlined,
                                size: 18, color: colorScheme.tertiaryFixed),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Métricas Rápidas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      isLoading
                        ? Row(children: [
                            const CorvusSkeleton(width: 36, height: 36, borderRadius: BorderRadius.all(Radius.circular(10))),
                            const SizedBox(width: 12),
                            const CorvusSkeleton(height: 20, width: 200),
                          ])
                        : _MetricRow(
                            icon: Icons.group,
                            bgColor: colorScheme.primaryContainer,
                            fgColor: colorScheme.primary,
                            text: '${data?.studentsWithTeam} Alumnos con equipo',
                          ),
                      const SizedBox(height: 10),
                      isLoading
                        ? Row(children: [
                            const CorvusSkeleton(width: 36, height: 36, borderRadius: BorderRadius.all(Radius.circular(10))),
                            const SizedBox(width: 12),
                            const CorvusSkeleton(height: 20, width: 250),
                          ])
                        : _MetricRow(
                            icon: Icons.person_off,
                            bgColor: colorScheme.errorContainer,
                            fgColor: colorScheme.error,
                            text: '${data?.studentsWithoutTeam} Alumnos rezagados (sin equipo)',
                          ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/prof-project/${widget.projectId}/directory');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: colorScheme.primary,
                            overlayColor: colorScheme.primary.withValues(alpha: 0.12),
                          ),
                          child: const Text(
                            'Ver Directorio de Alumnos Rezagados',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color fgColor;
  final String text;

  const _MetricRow({
    required this.icon,
    required this.bgColor,
    required this.fgColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: fgColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}