import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/l10n/app_localizations.dart';

class MyProjectsDashboardPage extends StatefulWidget {
  const MyProjectsDashboardPage({super.key});

  @override
  State<MyProjectsDashboardPage> createState() => _MyProjectsDashboardPageState();
}

class _MyProjectsDashboardPageState extends State<MyProjectsDashboardPage> {
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
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
        floatingActionButton: context.select<ProjectProvider, bool>((p) => p.myProjects.isNotEmpty) && !_isSelectionMode ? FloatingActionButton.extended(
          onPressed: () => context.push('/join-project'),
          icon: const Icon(Icons.add),
          label: Text(l10n.join),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ) : null,
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myProjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myProjects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.class_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noClassesYet,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noClassesDesc,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    CorvusButton(
                      text: l10n.joinClass,
                      onPressed: () => context.push('/join-project'),
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.myProjects.length + 1,
                itemBuilder: (context, index) {
                if (index == provider.myProjects.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 100.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.archive_outlined),
                        label: const Text('Mostrar proyectos archivados'),
                        onPressed: () {
                          context.push('/archived-projects');
                        },
                      ),
                    ),
                  );
                }
                final project = provider.myProjects[index];
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
                          if (context.mounted) context.push('/project/${project['id']}?tab=0');
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
                },
              ),
            );
        },
      ),
    );
  }
}