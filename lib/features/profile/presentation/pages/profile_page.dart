import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showUpcomingFeature(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureUpcoming),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header Profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Nombre de Alumno',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'correo@institucional.edu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.school_outlined,
                    value: '4.8',
                    label: l10n.gpa,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.account_tree_outlined,
                    value: '12',
                    label: l10n.projects,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Habilidades Técnicas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.technicalSkills,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(context, 'React'),
                      _buildChip(context, 'Node.js'),
                      _buildChip(context, 'Python'),
                      _buildChip(context, 'TypeScript'),
                      _buildChip(context, 'PostgreSQL'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Actividad Reciente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.recentActivity,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildActivityItem(
                    context,
                    icon: Icons.update,
                    title: l10n.ragEngineUpdate,
                    time: l10n.timeTwoHoursAgo,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  _buildActivityItem(
                    context,
                    icon: Icons.menu_book,
                    title: l10n.readingCompleted,
                    time: l10n.timeYesterday,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Selector de Apariencia
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.appearance,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.settings),
                          label: Text(l10n.themeSystem),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.wb_sunny),
                          label: Text(l10n.themeLight),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.nightlight_round),
                          label: Text(l10n.themeDark),
                        ),
                      ],
                      selected: {context.watch<ThemeProvider>().themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        context.read<ThemeProvider>().setThemeMode(newSelection.first);
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Cerrar Sesión
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Mostrar overlay oscuro de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  // Ejecutar logout que limpiará Google y storage
                  await context.read<AuthProvider>().logout();
                  
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Cerrar overlay
                    context.go('/');
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required String value, required String label}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, {required IconData icon, required String title, required String time}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
