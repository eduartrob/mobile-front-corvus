import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/features/prof_dash/presentation/provider/prof_directory_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';
import 'package:mobile/features/student_directory/presentation/widgets/student_card.dart';
import 'package:mobile/shared/widgets/corvus_skeleton.dart';

class ProfDirectoryPage extends StatelessWidget {
  final String projectId;
  const ProfDirectoryPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfDirectoryProvider(
        authProvider: context.read<AuthProvider>(),
        projectId: projectId,
      )..loadDirectory(),
      child: const _ProfDirectoryPageView(),
    );
  }
}

class _ProfDirectoryPageView extends StatefulWidget {
  const _ProfDirectoryPageView();

  @override
  State<_ProfDirectoryPageView> createState() => _ProfDirectoryPageViewState();
}

class _ProfDirectoryPageViewState extends State<_ProfDirectoryPageView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<ProfDirectoryProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CorvusTopBar(
        titleWidget: Text(
          'Directorio del Salón',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.4),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelColor: colorScheme.onSurface,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              unselectedLabelColor: colorScheme.onSurfaceVariant.withOpacity(0.7),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
              tabs: const [
                Tab(text: 'Equipos Formados'),
                Tab(text: 'Sin Equipo'),
              ],
            ),
          ),
          Expanded(
            child: (provider.isLoading && provider.directoryData == null)
                ? ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: 5,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, __) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CorvusSkeleton(width: 50, height: 50, borderRadius: BorderRadius.all(Radius.circular(25))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                CorvusSkeleton(height: 16, width: 150),
                                SizedBox(height: 8),
                                CorvusSkeleton(height: 12, width: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : provider.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(provider.errorMessage!, style: TextStyle(color: colorScheme.error)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: provider.loadDirectory,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTeamsList(provider.directoryData?.teams ?? [], colorScheme),
                          _buildStudentsList(provider.directoryData?.studentsWithoutTeam ?? []),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsList(List<TeamModel> teams, ColorScheme colorScheme) {
    if (teams.isEmpty) {
      return Center(
        child: Text(
          'No hay equipos formados.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        team.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${team.members.length} / ${team.maxMembers} alumnos',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  team.project?['title'] ?? 'Sin proyecto',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (team.members.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Integrantes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: team.members.map((member) {
                      final hasAvatar = member.avatarUrl != null && member.avatarUrl!.trim().isNotEmpty;
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          backgroundImage: hasAvatar ? NetworkImage(member.avatarUrl!) : null,
                          child: !hasAvatar ? Text(
                            (member.name ?? '?').isNotEmpty ? (member.name ?? '?')[0].toUpperCase() : '?',
                            style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ) : null,
                        ),
                        label: Text(member.name ?? 'Sin nombre', style: const TextStyle(fontSize: 12)),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsList(List<Student> students) {
    if (students.isEmpty) {
      return Center(
        child: Text(
          'No hay alumnos sin equipo.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        // student.email is not available in Student model from teams_model
        // But we can use StudentCard just passing what we have.
        // Wait, StudentCard might require specific provider. Let's just build a custom ListTile to avoid issues.
        final hasAvatar = student.avatarUrl != null && student.avatarUrl!.trim().isNotEmpty;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: hasAvatar ? NetworkImage(student.avatarUrl!) : null,
              child: !hasAvatar ? Text(
                (student.name ?? student.username ?? '?').isNotEmpty ? (student.name ?? student.username ?? '?')[0].toUpperCase() : '?',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ) : null,
            ),
            title: Text(student.name ?? student.username ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: student.tags.isNotEmpty 
                ? Text(student.tags.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis)
                : const Text('Sin habilidades destacadas'),
          ),
        );
      },
    );
  }
}
