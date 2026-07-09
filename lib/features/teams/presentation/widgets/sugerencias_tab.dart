import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'team_members_list.dart';

class SugerenciasTab extends StatefulWidget {
  const SugerenciasTab({super.key});

  @override
  State<SugerenciasTab> createState() => _SugerenciasTabState();
}

class _SugerenciasTabState extends State<SugerenciasTab> {
  String _selectedSkill = 'All Skills';
  String _searchQuery = '';
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _skills = [
    'All Skills',
    'React',
    'Python',
    'AI/ML',
    'UI/UX',
    'Flutter',
    'Go',
  ];

  @override
  void dispose() {
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
      provider.fetchSuggestions(skill: _selectedSkill, search: _searchQuery);
    });
  }

  void _showFilterSheet(BuildContext context, TeamsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _skills.length,
                  itemBuilder: (context, index) {
                    final skill = _skills[index];
                    return ListTile(
                      title: Text(skill),
                      trailing: _selectedSkill == skill ? const Icon(Icons.check, color: Colors.blue) : null,
                      onTap: () {
                        setState(() {
                          _selectedSkill = skill;
                        });
                        provider.fetchSuggestions(skill: _selectedSkill, search: _searchQuery);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TeamsProvider>(
      builder: (context, provider, child) {
        final suggestions = provider.suggestions;
        final isFiltering = _selectedSkill != 'All Skills' || _searchQuery.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar and Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => _onSearchChanged(val, provider),
                      decoration: InputDecoration(
                        hintText: 'Buscar compañero...',
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => _showFilterSheet(context, provider),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedSkill != 'All Skills' ? colorScheme.primaryContainer : colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedSkill != 'All Skills' ? colorScheme.primary : colorScheme.outlineVariant,
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: _selectedSkill != 'All Skills' ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Header Text (Recomendados vs Resultados)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                isFiltering ? 'Resultados de búsqueda' : 'Recomendados para ti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // List of filtered suggestions cards
            Expanded(
              child: provider.isLoading && suggestions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null && suggestions.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  'Error al cargar sugerencias:\n${provider.errorMessage}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => provider.fetchSuggestions(skill: _selectedSkill, search: _searchQuery),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : suggestions.isEmpty
                          ? Center(
                              child: Text(
                                'No hay sugerencias encontradas',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => provider.fetchSuggestions(skill: _selectedSkill, search: _searchQuery),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                itemCount: suggestions.length,
                                itemBuilder: (context, index) {
                                  final student = suggestions[index];
                                  return InvitationCard(
                                    name: student.name,
                                    username: student.username,
                                    bio: student.bio,
                                    tags: student.tags,
                                    avatarUrl: student.avatarUrl,
                                    isVerified: student.isVerified,
                                    onSendRequest: () {
                                      if (student.id != null) {
                                        provider.sendInvitation(student.id!).then((_) {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Invitación enviada a ${student.name}'),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }).catchError((error) {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error al enviar invitación: $error'),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
            ),
          ],
        );
      },
    );
  }
}
