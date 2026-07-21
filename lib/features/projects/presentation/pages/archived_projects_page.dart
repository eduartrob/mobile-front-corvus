import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/l10n/app_localizations.dart';

class ArchivedProjectsPage extends StatefulWidget {
  const ArchivedProjectsPage({super.key});

  @override
  State<ArchivedProjectsPage> createState() => _ArchivedProjectsPageState();
}

class _ArchivedProjectsPageState extends State<ArchivedProjectsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().currentUser?.token;
      if (token != null) {
        final provider = context.read<ProjectProvider>();
        if (provider.archivedProjects.isEmpty) {
          provider.loadArchivedProjects(token);
        } else {
          // Load quietly in background if already has data
          provider.loadArchivedProjects(token, quiet: true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos Archivados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.archivedProjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.archivedProjects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.archive, size: 80, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 24),
                    Text(
                      'No hay proyectos archivados',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Los proyectos que archives aparecerán aquí.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final token = context.read<AuthProvider>().currentUser?.token;
              if (token != null) {
                await provider.loadArchivedProjects(token);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.archivedProjects.length,
              itemBuilder: (context, index) {
                final project = provider.archivedProjects[index];
                final pastelColors = const [
                  Color(0xFF5C88DA),
                  Color(0xFF9A73C9),
                  Color(0xFF56A98A),
                  Color(0xFFD98A53),
                  Color(0xFFD67389),
                ];
                Color bgColor;
                if (project['theme_color'] != null) {
                  final colorStr = project['theme_color'].toString().replaceAll('#', '0xFF');
                  bgColor = Color(int.parse(colorStr));
                } else {
                  bgColor = pastelColors[project['id'].hashCode.abs() % pastelColors.length];
                }
                final String? patternName = project['theme_pattern'];

                // Hacemos que se vea "desactivado" al reducir la opacidad
                return Opacity(
                  opacity: 0.7,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        splashColor: Colors.black.withValues(alpha: 0.12),
                        highlightColor: Colors.black.withValues(alpha: 0.04),
                        onTap: () {
                          // Opcional: Permitir entrar en solo lectura
                          if (context.mounted) context.push('/project/${project['id']}?tab=0');
                        },
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
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.archive_outlined, color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          project['name'] ?? l10n.defaultProjectName,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                                    ],
                                  ),
                                  if (project['description'] != null && project['description'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      project['description'].toString(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.85),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
