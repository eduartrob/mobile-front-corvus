import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'team_members_list.dart';

class SugerenciasTab extends StatelessWidget {
  final bool isFiltering;
  
  const SugerenciasTab({super.key, this.isFiltering = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TeamsProvider>(
      builder: (context, provider, child) {
        final suggestions = provider.suggestions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                                  onPressed: () => provider.fetchSuggestions(), // TeamProvider will use previous values if modified or we just let it fetch default
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : suggestions.isEmpty
                          ? RefreshIndicator(
                              onRefresh: () => provider.fetchSuggestions(),
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: Center(
                                      child: Text(
                                        'No hay sugerencias encontradas',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => provider.fetchSuggestions(),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                itemCount: suggestions.length,
                                itemBuilder: (context, index) {
                                  final student = suggestions[index];
                                  final iHaveTeam = provider.myTeam != null && provider.myTeam!.members.length > 1;
                                  
                                  return InvitationCard(
                                    name: student.name,
                                    username: student.username,
                                    bio: student.bio,
                                    tags: student.tags,
                                    avatarUrl: student.avatarUrl,
                                    isVerified: student.isVerified,
                                    targetHasTeam: student.hasTeam,
                                    iHaveTeam: iHaveTeam,
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
                                              content: Text('Error al enviar invitación: ${error.toString().replaceAll('Exception: ', '')}'),
                                              backgroundColor: Theme.of(context).colorScheme.error,
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
