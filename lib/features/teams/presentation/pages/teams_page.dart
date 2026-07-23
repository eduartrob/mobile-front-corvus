import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/profile/data/models/profile_completo_model.dart';
import '../provider/teams_provider.dart';
import '../widgets/equipo_tab.dart';
import '../widgets/solicitudes_tab.dart';
import '../widgets/sugerencias_tab.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeamsPage extends StatefulWidget {
  final int initialTabIndex;
  final String projectId;
  const TeamsPage({super.key, this.initialTabIndex = 0, required this.projectId});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  String _selectedSkill = '';
  String _searchQuery = '';
  bool _showAllStudents = false;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  List<String> get _skills {
    try {
      final profileProvider = context.read<ProfileProvider>();
      final profile = profileProvider.profile;
      if (profile == null || profile.habilidades.isEmpty) return [];
      
      final sortedSkills = List<HabilidadModel>.from(profile.habilidades)
        ..sort((a, b) => b.porcentaje.compareTo(a.porcentaje));
        
      return sortedSkills.take(5).map((e) => e.habilidad).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      setState(() {});
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
        teamsProvider.fetchMyTeam(projectId: widget.projectId);
        teamsProvider.fetchSuggestions(skill: _selectedSkill, search: _searchQuery, showAll: _showAllStudents, projectId: widget.projectId);
        teamsProvider.fetchRequests(projectId: widget.projectId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, TeamsProvider provider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      provider.fetchSuggestions(skill: _selectedSkill, search: _searchQuery, showAll: _showAllStudents);
    });
  }

  void _showFilterSheet(BuildContext context, TeamsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filtrar por Tecnología',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Todas las habilidades'),
                    trailing: _showAllStudents ? const Icon(Icons.check, color: Colors.blue) : null,
                    onTap: () {
                      setState(() {
                        _showAllStudents = !_showAllStudents;
                      });
                      setSheetState(() {});
                      provider.fetchSuggestions(skill: _selectedSkill, search: _searchQuery, showAll: _showAllStudents);
                      Navigator.pop(context);
                    },
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _skills.length,
                      itemBuilder: (context, index) {
                        final skill = _skills[index];
                        final isSelected = _selectedSkill == skill;
                        return ListTile(
                          title: Text(skill),
                          trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                          onTap: () {
                            setState(() {
                              if (_selectedSkill == skill) {
                                _selectedSkill = '';
                              } else {
                                _selectedSkill = skill;
                              }
                            });
                            provider.fetchSuggestions(skill: _selectedSkill, search: _searchQuery, showAll: _showAllStudents);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  PreferredSizeWidget _buildSolicitudesTopBar(BuildContext context, TeamsProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            children: [
              _buildFilterChip(
                context,
                label: l10n.received,
                filter: SolicitudFilter.recibidas,
                currentFilter: provider.selectedFilter,
                onTap: (filter) => provider.selectFilter(filter),
              ),
              const SizedBox(width: 10),
              _buildFilterChip(
                context,
                label: l10n.sent,
                filter: SolicitudFilter.enviadas,
                currentFilter: provider.selectedFilter,
                onTap: (filter) => provider.selectFilter(filter),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required SolicitudFilter filter,
    required SolicitudFilter currentFilter,
    required ValueChanged<SolicitudFilter> onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = currentFilter == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(filter),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().currentUser;
    final provider = context.watch<TeamsProvider>();
    final myAvatarUrl = user?.photoUrl ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _tabController.index == 0 
          ? const CorvusTopBar() 
          : _buildSolicitudesTopBar(context, provider),
      body: Column(
        children: [
          // TabBar container
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelColor: colorScheme.onSurface,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              unselectedLabelColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Equipo'),
                Tab(text: 'Solicitudes'),
                Tab(text: 'Sugerencias'),
              ],
            ),
          ),
          // Tab contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Equipo
                EquipoTab(
                  myAvatarUrl: myAvatarUrl,
                  userName: user?.name,
                  userEmail: user?.email,
                  projectId: widget.projectId,
                  onSearchMembers: () {
                    _tabController.animateTo(2); // Redirects to tab index 2 (Sugerencias)
                  },
                  onLeaveTeam: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        final colorScheme = Theme.of(dialogContext).colorScheme;
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          icon: Icon(
                            Icons.warning_amber_rounded,
                            color: colorScheme.error,
                            size: 40,
                          ),
                          title: Text(
                            '¿Abandonar el equipo?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          content: Text(
                            'Si abandonas el equipo, perderás el acceso a la información y deberás ser invitado nuevamente para volver. ¿Estás seguro?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                          actions: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                context.read<TeamsProvider>().leaveTeam().then((_) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Has abandonado el equipo'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }).catchError((error) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $error'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Abandonar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                // Tab 2: Solicitudes
                const SolicitudesTab(),
                // Tab 3: Sugerencias
                SugerenciasTab(isFiltering: _selectedSkill.isNotEmpty || _searchQuery.isNotEmpty),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
