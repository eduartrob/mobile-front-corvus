import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/prof_rules/presentation/provider/prof_rules_provider.dart';
import 'package:mobile/features/prof_rules/data/data_source/prof_rules_remote_data_source.dart';
import 'package:http/http.dart' as http;

class ProfRulesPage extends StatelessWidget {
  const ProfRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = ProfRulesProvider(
          remoteDataSource: ProfRulesRemoteDataSource(client: http.Client()),
        );
        provider.fetchData();
        return provider;
      },
      child: const _ProfRulesPageView(),
    );
  }
}

class _ProfRulesPageView extends StatelessWidget {
  const _ProfRulesPageView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ProfRulesProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const CorvusTopBar(),
        body: (provider.isLoading && provider.clusterStats.isEmpty && provider.projectSections.isEmpty)
            ? const _ProfRulesLoadingSkeleton()
            : Column(
                children: [
                  TabBar(
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Reglas de Exclusión'),
                      Tab(text: 'Estructura del Proyecto'),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        _ExclusionRulesTab(),
                        _ProjectStructureTab(),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: provider.isLoading
            ? null
            : Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);
                  return AnimatedBuilder(
                    animation: tabController,
                    builder: (context, child) {
                      if (tabController.index != 1) return const SizedBox.shrink();
                      return FloatingActionButton.extended(
                        onPressed: provider.isSaving ? null : () => _saveRules(context, provider),
                        icon: provider.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(provider.isSaving ? 'Guardando...' : 'Guardar y Notificar'),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  void _saveRules(BuildContext context, ProfRulesProvider provider) async {
    await provider.saveConfig();
    if (context.mounted) {
      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${provider.errorMessage}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reglas actualizadas y notificación enviada.')),
        );
      }
    }
  }
}

class _ExclusionRulesTab extends StatelessWidget {
  const _ExclusionRulesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfRulesProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final sortedClusters = List<dynamic>.from(provider.clusterStats);
    sortedClusters.sort((a, b) {
      final nameA = a['cluster_name'] ?? 'Clúster ${a['cluster_id']}';
      final nameB = b['cluster_name'] ?? 'Clúster ${b['cluster_id']}';
      final isBlockedA = provider.exclusionRules.contains(nameA);
      final isBlockedB = provider.exclusionRules.contains(nameB);
      
      if (isBlockedA == isBlockedB) {
        return nameA.compareTo(nameB);
      }
      return isBlockedA ? 1 : -1;
    });

    return RefreshIndicator(
      onRefresh: () => provider.fetchData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(Icons.block, color: colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Temas Bloqueados',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tooltip(
                message: 'Selecciona los clústeres o temas que deseas bloquear para futuros proyectos integradores. Los alumnos no podrán presentar propuestas relacionadas con estos temas.',
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(color: colorScheme.onInverseSurface, fontSize: 14),
                child: IconButton(
                  icon: Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
                  onPressed: () {}, // Tooltip handles tap
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (sortedClusters.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No hay clústeres disponibles actualmente.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ListView.separated(
                key: ValueKey(sortedClusters.map((e) => e['cluster_name']).join('-')),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedClusters.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final cluster = sortedClusters[index];
                  final clusterName = cluster['cluster_name'] ?? 'Clúster ${cluster['cluster_id']}';
                  final isBlocked = provider.exclusionRules.contains(clusterName);

                  return ListTile(
                    key: ValueKey(clusterName),
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isBlocked ? colorScheme.errorContainer : colorScheme.primaryContainer.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBlocked ? Icons.block : Icons.category,
                        color: isBlocked ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      clusterName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isBlocked ? colorScheme.error : colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text('${cluster['project_count']} proyectos actuales en este tema'),
                    trailing: Switch(
                      value: isBlocked,
                      activeThumbColor: colorScheme.error,
                      onChanged: (value) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final scheme = Theme.of(context).colorScheme;
                        provider.toggleExclusionRule(clusterName);
                        await provider.saveConfig();
                        
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(value ? Icons.lock_outline : Icons.lock_open_rounded, color: scheme.onInverseSurface, size: 20),
                                const SizedBox(width: 8),
                                Text(value ? 'Tema bloqueado' : 'Tema desbloqueado', style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            width: 220, // Ancho fijo para que parezca una píldora (Toast)
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Bordes totalmente redondos
                            backgroundColor: scheme.inverseSurface,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectStructureTab extends StatelessWidget {
  const _ProjectStructureTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfRulesProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => provider.fetchData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Estructura del Proyecto',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tooltip(
                message: 'Define las secciones obligatorias que debe contener el documento de la propuesta.',
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(color: colorScheme.onInverseSurface, fontSize: 14),
                child: IconButton(
                  icon: Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
                  onPressed: () {}, // Tooltip handles tap
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Secciones (${provider.projectSections.length})',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: provider.isLoading ? null : () => _addSectionDialog(context, provider),
                    icon: Icon(Icons.add_circle, color: colorScheme.primary),
                    tooltip: 'Añadir sección manual',
                  ),
                  OutlinedButton.icon(
                    onPressed: provider.isLoading ? null : () => _generateSectionsDialog(context, provider),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('IA'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.projectSections.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No hay secciones definidas.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.projectSections.length,
              itemBuilder: (context, index) {
                final section = provider.projectSections[index];
                final name = section['nombre'] ?? '';
                final isObligatory = section['obligatoria'] ?? false;
                final keywords = (section['keywords'] as List<dynamic>?)?.map((e) => e.toString()).join(', ') ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isObligatory ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isObligatory ? 'Obligatoria' : 'Opcional',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isObligatory ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: colorScheme.error),
                              onPressed: () => provider.removeSection(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Palabras clave: $keywords',
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
      ),
    );
  }

  void _addSectionDialog(BuildContext context, ProfRulesProvider provider) {
    final nameController = TextEditingController();
    final keywordsController = TextEditingController();
    bool isObligatory = true;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
              backgroundColor: colorScheme.surface,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Titulo con Icono
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.note_add_outlined, color: colorScheme.onPrimaryContainer),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Nueva Sección',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      
                      // TextField de Nombre
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la sección',
                          hintText: 'Ej. Introducción',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // TextField de Palabras Clave
                      TextField(
                        controller: keywordsController,
                        decoration: InputDecoration(
                          labelText: 'Palabras clave',
                          hintText: 'Ej. contexto, objetivos',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Toggle de Obligatoria
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SwitchListTile(
                          title: const Text('Sección Obligatoria', style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('Requerida para la evaluación', style: TextStyle(fontSize: 12)),
                          value: isObligatory,
                          activeThumbColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onChanged: (val) {
                            setState(() {
                              isObligatory = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                final name = nameController.text.trim();
                                if (name.isNotEmpty) {
                                  final kwList = keywordsController.text
                                      .split(',')
                                      .map((e) => e.trim())
                                      .where((e) => e.isNotEmpty)
                                      .toList();
                                  provider.addSection(name, kwList, isObligatory);
                                  Navigator.pop(ctx);
                                }
                              },
                              child: const Text('Añadir', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _generateSectionsDialog(BuildContext context, ProfRulesProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generar con IA'),
        content: const Text(
          'Esto reemplazará las secciones actuales con una estructura sugerida por el modelo de IA configurado para un proyecto integrador. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.generateSectionsWithAI();
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }
}

class _ProfRulesLoadingSkeleton extends StatefulWidget {
  const _ProfRulesLoadingSkeleton();

  @override
  State<_ProfRulesLoadingSkeleton> createState() => _ProfRulesLoadingSkeletonState();
}

class _ProfRulesLoadingSkeletonState extends State<_ProfRulesLoadingSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSkeletonBox({double? width, double? height, double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Column(
        children: [
          // Simulated TabBar
          Container(
            height: 48,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(child: Center(child: _buildSkeletonBox(width: 120, height: 20))),
                Expanded(child: Center(child: _buildSkeletonBox(width: 150, height: 20))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, _) => Row(
                  children: [
                    _buildSkeletonBox(width: 40, height: 40, borderRadius: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSkeletonBox(width: 180, height: 16),
                          const SizedBox(height: 8),
                          _buildSkeletonBox(width: 120, height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildSkeletonBox(width: 40, height: 24, borderRadius: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

