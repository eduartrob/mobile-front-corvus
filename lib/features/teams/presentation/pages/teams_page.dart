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
          : PreferredSize(
              preferredSize: const Size.fromHeight(80.0),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => _onSearchChanged(val, provider),
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Buscar compañero...',
                              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                              prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.7)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(26),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(26),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(26),
                                borderSide: BorderSide(
                                  color: colorScheme.primary.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              filled: true,
                              fillColor: colorScheme.primaryContainer.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => _showFilterSheet(context, provider),
                        borderRadius: BorderRadius.circular(26),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _selectedSkill.isNotEmpty || _showAllStudents
                                ? colorScheme.primaryContainer 
                                : colorScheme.primaryContainer.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: _selectedSkill.isNotEmpty ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
