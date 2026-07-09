import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/student_directory_provider.dart';
import '../widgets/student_search_bar.dart';
import '../widgets/skill_filter_chips.dart';
import '../widgets/student_card.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/teams/data/data_source/teams_remote_data_source.dart';

class StudentDirectoryPage extends StatelessWidget {
  const StudentDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentDirectoryProvider(
        remoteDataSource: TeamsRemoteDataSource(client: apiClient),
      ),
      child: const _StudentDirectoryView(),
    );
  }
}

class _StudentDirectoryView extends StatelessWidget {
  const _StudentDirectoryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredStudents = context.watch<StudentDirectoryProvider>().filteredStudents;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / Description Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Directorio de estudiantes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Busca e invita a compañeros de clase a colaborar en tu próximo proyecto integrador',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: StudentSearchBar(),
            ),
            
            const SizedBox(height: 12),
            
            // Filter Chips Section
            const Padding(
              padding: EdgeInsets.only(left: 20.0, bottom: 16.0),
              child: SkillFilterChips(),
            ),
            
            // Student List
            Expanded(
              child: context.watch<StudentDirectoryProvider>().isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: context.read<StudentDirectoryProvider>().refresh,
                      child: filteredStudents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron estudiantes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return StudentCard(student: student);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
