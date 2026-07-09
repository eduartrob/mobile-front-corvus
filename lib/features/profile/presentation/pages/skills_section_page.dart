import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/profile/presentation/pages/edit_skills_page.dart';
import 'package:mobile/features/profile/presentation/widgets/technical_skills_section.dart';

class SkillsSectionPage extends StatelessWidget {
  const SkillsSectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Habilidades', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditSkillsPage(
                    initialSkills: profile?.habilidades.map((e) => e.habilidad).toList() ?? [],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: TechnicalSkillsSection(),
      ),
    );
  }
}
