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

class ProfProjectsDashboardPage extends StatefulWidget {
  const ProfProjectsDashboardPage({super.key});

  @override
  State<ProfProjectsDashboardPage> createState() =>
      _ProfProjectsDashboardPageState();
}

class _ProfProjectsDashboardPageState extends State<ProfProjectsDashboardPage> {
  DateTime? _lastPressedAt;
  Timer? _pollTimer;

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
        appBar: const CorvusTopBar(),
        floatingActionButton: context.select<ProjectProvider, bool>((p) => p.myProjects.isNotEmpty || p.invitations.isNotEmpty) ? Column(
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
              itemBuilder: (_, __) => Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CorvusSkeleton(height: 24, width: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
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
              ),
            );
          }

          if (provider.myProjects.isEmpty && provider.invitations.isEmpty) {
            return Center(
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
                padding: const EdgeInsets.all(16),
                children: [
                  if (provider.myProjects.isNotEmpty) ...[
                    ...provider.myProjects.map(
                      (project) => _buildProjectCard(context, project),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/prof-project/${project['id']}/dashboard');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.class_,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      project['name'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ],
              ),
              if (project['description'] != null &&
                  project['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project['description'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Código: ${project['code']} • Equipos max: ${project['team_size']}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
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
