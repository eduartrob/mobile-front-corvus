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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TeamsProvider>(
      builder: (context, provider, child) {
        final suggestions = provider.suggestions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal Scroll Skills Selector
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: _skills.length,
                itemBuilder: (context, index) {
                  final skill = _skills[index];
                  final isSelected = _selectedSkill == skill;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedSkill = skill;
                          });
                          // Fetch suggestions filtered by selected skill
                          provider.fetchSuggestions(skill: skill);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
                                  onPressed: () => provider.fetchSuggestions(skill: _selectedSkill),
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
                                'No hay sugerencias con esta habilidad',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => provider.fetchSuggestions(skill: _selectedSkill),
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
