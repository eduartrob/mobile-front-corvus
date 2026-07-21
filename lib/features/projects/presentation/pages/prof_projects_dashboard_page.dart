import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/shared/widgets/corvus_skeleton.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfProjectsDashboardPage extends StatefulWidget {
  const ProfProjectsDashboardPage({super.key});

  @override
  State<ProfProjectsDashboardPage> createState() =>
      _ProfProjectsDashboardPageState();
}

class _ProfProjectsDashboardPageState extends State<ProfProjectsDashboardPage> {
  DateTime? _lastPressedAt;
  Timer? _pollTimer;
  final Set<String> _selectedProjects = {};
  bool _isSelectionMode = false;

  void _toggleSelection(String projectId) {
    setState(() {
      if (_selectedProjects.contains(projectId)) {
        _selectedProjects.remove(projectId);
        if (_selectedProjects.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedProjects.add(projectId);
        _isSelectionMode = true;
      }
    });
  }

  void _archiveSelectedProjects() async {
    final token = context.read<AuthProvider>().currentUser?.token;
    if (token == null || _selectedProjects.isEmpty) return;

    final success = await context.read<ProjectProvider>().archiveProjects(
      projectIds: _selectedProjects.toList(),
      token: token,
    );

    if (success && mounted) {
      setState(() {
        _selectedProjects.clear();
        _isSelectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyectos archivados exitosamente')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().currentUser?.token;
      if (token != null) {
        context.read<ProjectProvider>().loadMyProjects(token);
        
        // Configurar polling automático cada 10 segundos
        _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (mounted) {
            final currentToken = context.read<AuthProvider>().currentUser?.token;
            if (currentToken != null) {
              context.read<ProjectProvider>().loadMyProjects(currentToken, quiet: true);
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Toca "Volver" de nuevo para salir'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: _isSelectionMode 
          ? AppBar(
              title: Text('${_selectedProjects.length} seleccionados'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedProjects.clear();
                    _isSelectionMode = false;
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.archive),
                  tooltip: 'Archivar seleccionados',
                  onPressed: _archiveSelectedProjects,
                ),
              ],
            )
          : const CorvusTopBar(),
        floatingActionButton: context.select<ProjectProvider, bool>((p) => p.myProjects.isNotEmpty || p.invitations.isNotEmpty) && !_isSelectionMode ? Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'join_project',
              onPressed: () => context.push('/join-project'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Unirse'),
              elevation: 1, // Reduced shadow
              backgroundColor: Theme.of(
                context,
              ).colorScheme.tertiaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onTertiaryContainer,
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: 'create_project',
              onPressed: () => context.push('/prof-create-project'),
              icon: const Icon(Icons.add),
              label: const Text('Crear Clase'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ) : null,
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading &&
              provider.myProjects.isEmpty &&
              provider.invitations.isEmpty) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF4FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        CorvusSkeleton(height: 36, width: 36, borderRadius: BorderRadius.all(Radius.circular(8))),
                        SizedBox(width: 12),
                        CorvusSkeleton(height: 20, width: 150),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const CorvusSkeleton(height: 14, width: double.infinity),
                    const SizedBox(height: 6),
                    const CorvusSkeleton(height: 14, width: 200),
                  ],
                ),
              ),
            );
          }

          if (provider.myProjects.isEmpty && provider.invitations.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                final token = context.read<AuthProvider>().currentUser?.token;
                if (token != null) {
                  await provider.loadMyProjects(token);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.class_outlined,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Aún no tienes proyectos',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Crea una clase (proyecto) para que tus alumnos puedan unirse, formar equipos y enviar sus propuestas.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          CorvusButton(
                            text: 'Crear Proyecto (Clase)',
                            onPressed: () => context.push('/prof-create-project'),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/join-project'),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Unirse a un Proyecto'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
              onRefresh: () async {
                final token = context.read<AuthProvider>().currentUser?.token;
                if (token != null) {
                  await provider.loadMyProjects(token);
                }
              },
              child: ListView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                children: [
                  if (provider.myProjects.isNotEmpty) ...[
                    ...provider.myProjects.map(
                      (project) => _buildProjectCard(context, project),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.archive_outlined),
                          label: const Text('Mostrar proyectos archivados'),
                          onPressed: () {
                            context.push('/archived-projects');
                          },
                        ),
                      ),
                    ),
                  ],
                  if (provider.myProjects.isEmpty &&
                      provider.invitations.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        'Aún no tienes proyectos creados',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (provider.invitations.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'Invitaciones',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    ...provider.invitations.map(
                      (project) =>
                          _buildInvitationCard(context, project, provider),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, dynamic project) {
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
      final colorIndex = project['id'].hashCode.abs() % pastelColors.length;
      bgColor = pastelColors[colorIndex];
    }
    
    final String? patternName = project['theme_pattern'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.black.withValues(alpha: 0.12),
          highlightColor: Colors.black.withValues(alpha: 0.04),
          onLongPress: () {
            _toggleSelection(project['id']);
          },
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(project['id']);
            } else {
              if (context.mounted) context.push('/prof-project/${project['id']}?tab=0');
            }
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
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                  ],
                ),
                if (project['description'] != null &&
                    project['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    project['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Código: ${project['code']} • Equipos max: ${project['team_size']}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (_isSelectionMode)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedProjects.contains(project['id'])
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.check,
                    size: 20,
                    color: _selectedProjects.contains(project['id'])
                        ? Theme.of(context).colorScheme.onPrimary
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildInvitationCard(
    BuildContext context,
    dynamic project,
    ProjectProvider provider,
  ) {
    final cardColors = [
      const Color(0xFFFDE4C3), // Peach
      const Color(0xFFE4F0ED), // Mint
      const Color(0xFFE1DDF6), // Lavender
    ];
    final cardColor = cardColors[project['id'].hashCode.abs() % cardColors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (project['creator'] != null)
                        Text(
                          '${project['creator']['full_name'] ?? 'Un profesor'} te está invitando para ser colaborador',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        project['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ],
            ),
            if (project['description'] != null &&
                project['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                project['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final token = context.read<AuthProvider>().currentUser?.token;
                      if (token != null) {
                        final success = await provider.rejectProjectInvitation(
                          projectId: project['id'],
                          token: token,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invitación eliminada')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.close),
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final token = context.read<AuthProvider>().currentUser?.token;
                      if (token != null) {
                        final success = await provider.acceptProjectInvitation(
                          projectId: project['id'],
                          token: token,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invitación aceptada')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
