import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/providers/saved_projects_provider.dart';
import 'package:mobile/shared/widgets/project_card.dart';

class SavedProjectsPage extends StatelessWidget {
  const SavedProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final savedProjectsProvider = context.watch<SavedProjectsProvider>();
    final projects = savedProjectsProvider.savedProjects;

    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Saved Projects' : 'Proyectos Guardados', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      body: projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    isEn ? 'No saved projects yet' : 'No tienes proyectos guardados',
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ProjectCard(project: project),
                );
              },
            ),
    );
  }
}
