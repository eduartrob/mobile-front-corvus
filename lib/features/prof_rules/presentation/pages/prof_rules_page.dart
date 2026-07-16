import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/prof_rules/presentation/provider/prof_rules_provider.dart';
import 'package:mobile/features/prof_rules/data/data_source/prof_rules_remote_data_source.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:http/http.dart' as http;

class ProfRulesPage extends StatelessWidget {
  final String projectId;
  const ProfRulesPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return _ProfRulesPageView(projectId: projectId);
  }
}

class _ProfRulesPageView extends StatefulWidget {
  final String projectId;
  const _ProfRulesPageView({required this.projectId});

  @override
  State<_ProfRulesPageView> createState() => _ProfRulesPageViewState();
}

class _ProfRulesPageViewState extends State<_ProfRulesPageView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfRulesProvider>().fetchData(projectId: widget.projectId);
    });
  }

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
                  Expanded(
                    child: TabBarView(
                      children: [
                        _ExclusionRulesTab(projectId: widget.projectId),
                        _ProjectStructureTab(projectId: widget.projectId),
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
    final user = context.read<AuthProvider>().currentUser;
    await provider.saveConfig(
      projectId: widget.projectId,
      authorName: user?.name,
      authorPhotoUrl: user?.photoUrl,
      authorId: user?.id,
    );
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
  final String projectId;
  const _ExclusionRulesTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfRulesProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final sortedClusters = List<Map<String, dynamic>>.from(provider.clusterStats);
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
      onRefresh: () => provider.fetchData(projectId: projectId),
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
                    fontSize: 18,
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
            ImplicitlyAnimatedList<Map<String, dynamic>>(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              items: sortedClusters,
              areItemsTheSame: (a, b) => a['cluster_name'] == b['cluster_name'],
              itemBuilder: (context, animation, item, index) {
                final clusterName = item['cluster_name'] ?? 'Clúster ${item['cluster_id']}';
                final isBlocked = provider.exclusionRules.contains(clusterName);

                return SizeFadeTransition(
                  sizeFraction: 0.7,
                  curve: Curves.easeInOut,
                  animation: animation,
                  child: Column(
                    children: [
                      ListTile(
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
                        subtitle: Text('${item['project_count']} proyectos actuales en este tema'),
                        trailing: Switch(
                          value: isBlocked,
                          activeThumbColor: colorScheme.error,
                          onChanged: (value) async {
                            final messenger = ScaffoldMessenger.of(context);
                            final scheme = Theme.of(context).colorScheme;
                            final user = context.read<AuthProvider>().currentUser;
                            provider.toggleExclusionRule(clusterName);
                            await provider.saveConfig(
                              projectId: projectId,
                              authorName: user?.name,
                              authorPhotoUrl: user?.photoUrl,
                              authorId: user?.id,
                            );
                            
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
                                width: 220,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                backgroundColor: scheme.inverseSurface,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      if (index < sortedClusters.length - 1) const Divider(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectStructureTab extends StatelessWidget {
  final String projectId;
  const _ProjectStructureTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfRulesProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => provider.fetchData(projectId: projectId),
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
          const SizedBox(height: 24),
          const _TeamLimitsEditor(),
          const SizedBox(height: 24),
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
                final descripcion = section['descripcion'] as String?;

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
                        const SizedBox(height: 8),
                        if (descripcion != null && descripcion.isNotEmpty) ...[
                          Text(
                            descripcion,
                            style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                        ],
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
    final descController = TextEditingController();

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

                      // TextField de Descripción
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descripción (Opcional)',
                          hintText: 'Ej. Escribe un resumen de...',
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
                                final desc = descController.text.trim();
                                if (name.isNotEmpty) {
                                  provider.addSection(name, [], isObligatory, descripcion: desc);
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

class _TeamLimitsEditor extends StatefulWidget {
  const _TeamLimitsEditor();

  @override
  State<_TeamLimitsEditor> createState() => _TeamLimitsEditorState();
}

class _TeamLimitsEditorState extends State<_TeamLimitsEditor> {
  late TextEditingController _minController;
  late TextEditingController _maxController;
  late FocusNode _minFocus;
  late FocusNode _maxFocus;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProfRulesProvider>();
    _minController = TextEditingController(text: provider.minTeamMembers.toString());
    _maxController = TextEditingController(text: provider.maxTeamMembers.toString());
    _minFocus = FocusNode()..addListener(_onFocusChange);
    _maxFocus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _minFocus.dispose();
    _maxFocus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_minFocus.hasFocus && !_maxFocus.hasFocus) {
      int min = int.tryParse(_minController.text) ?? 1;
      int max = int.tryParse(_maxController.text) ?? 5;

      if (min < 1) min = 1;
      if (max < min) max = min;

      if (_minController.text != min.toString()) {
        _minController.text = min.toString();
      }
      if (_maxController.text != max.toString()) {
        _maxController.text = max.toString();
      }
      
      _updateLimits();
    }
  }

  void _updateLimits() {
    final provider = context.read<ProfRulesProvider>();
    final min = int.tryParse(_minController.text) ?? 1;
    final max = int.tryParse(_maxController.text) ?? 5;
    provider.updateTeamLimits(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            const Text(
              'Límites de Integrantes por Equipo',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Define la cantidad mínima y máxima de alumnos permitidos por cada proyecto.',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    focusNode: _minFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Mínimo',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => _updateLimits(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('a', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    focusNode: _maxFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Máximo',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => _updateLimits(),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.group, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
