import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/features/teams/presentation/provider/solicitudes_provider.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';
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

  final List<Map<String, dynamic>> _candidates = [
    {
      'name': 'Elena Rodríguez',
      'username': '@elena_dev',
      'bio': 'Full-stack developer passionate about building scalable RAG applications and UI/UX',
      'tags': ['React', 'TypeScript', 'UI/UX'],
      'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    },
    {
      'name': 'Marcus Chen',
      'username': '@marcus_codes',
      'bio': 'Backend engineer specialized in Go, Python, and distributed systems architecture.',
      'tags': ['Go', 'Python', 'gRPC'],
      'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
    {
      'name': 'Sophia Patel',
      'username': '@sophia_data',
      'bio': 'Data Scientist focused on NLP, machine learning pipelines, and vector databases.',
      'tags': ['Python', 'PyTorch', 'NLP', 'AI/ML'],
      'avatarUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    },
    {
      'name': 'Mateo Ruiz',
      'username': '@mateo_ux',
      'bio': 'Product designer creating clean, accessible, and user-centered digital experiences.',
      'tags': ['Figma', 'UI/UX', 'Research'],
      'avatarUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final filteredCandidates = _selectedSkill == 'All Skills'
        ? _candidates
        : _candidates.where((c) {
            final tags = c['tags'] as List<String>;
            return tags.contains(_selectedSkill);
          }).toList();

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
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSkill = skill;
                    });
                  },
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
                            : colorScheme.outlineVariant.withOpacity(0.5),
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
              );
            },
          ),
        ),
        // List of filtered suggestions cards
        Expanded(
          child: filteredCandidates.isEmpty
              ? Center(
                  child: Text(
                    'No hay sugerencias con esta habilidad',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredCandidates.length,
                  itemBuilder: (context, index) {
                    final item = filteredCandidates[index];
                    return InvitationCard(
                      name: item['name'] as String,
                      username: item['username'] as String,
                      bio: item['bio'] as String,
                      tags: List<String>.from(item['tags'] as List),
                      avatarUrl: item['avatarUrl'] as String,
                      onSendRequest: () {
                        final student = Student(
                          name: item['name'] as String,
                          username: item['username'] as String,
                          bio: item['bio'] as String,
                          tags: List<String>.from(item['tags'] as List),
                          avatarUrl: item['avatarUrl'] as String,
                          isVerified: true,
                        );
                        context.read<SolicitudesProvider>().addSolicitud(student);

                        setState(() {
                          _candidates.removeWhere((c) => c['username'] == item['username']);
                        });

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Solicitud enviada a ${item['name']}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
