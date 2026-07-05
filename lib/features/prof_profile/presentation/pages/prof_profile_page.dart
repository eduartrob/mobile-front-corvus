import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/theme/app_dimens.dart';

import '../widgets/prof_header_info.dart';
import '../widgets/prof_stats_card.dart';

class ProfProfilePage extends StatefulWidget {
  const ProfProfilePage({super.key});

  @override
  State<ProfProfilePage> createState() => _ProfProfilePageState();
}

class _ProfProfilePageState extends State<ProfProfilePage> {
  bool course1Enabled = true;
  bool course2Enabled = true;
  bool course3Enabled = false;

  void _showUpcomingFeature(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.screenMargin),
        child: Column(
          children: [
            ProfHeaderInfo(user: user),
            const SizedBox(height: 32),
            const ProfStatsCard(),
            
            const SizedBox(height: 32),
            
            // Classroom Integration Section
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
                      Icon(Icons.school, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Integración Classroom',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sincroniza tus clases y materiales para permitir que los alumnos consulten dudas mediante la IA (solo lectura).',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final granted = await context.read<AuthProvider>().requestClassroomAccess();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(granted ? 'Permisos otorgados con éxito' : 'Error al solicitar permisos'),
                              backgroundColor: granted ? Colors.green : colorScheme.error,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.sync),
                      label: const Text('Sincronizar Material de Classroom'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Course\nAccess',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                InkWell(
                  onTap: () => _showUpcomingFeature(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Permissions\nManagement',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _buildCourseToggle(
                    context,
                    icon: Icons.code,
                    title: 'Software Engineering I',
                    subtitle: 'Undergraduate Core | 84 Students',
                    value: course1Enabled,
                    onChanged: (val) {
                      setState(() => course1Enabled = val);
                      _showUpcomingFeature(context);
                    },
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  _buildCourseToggle(
                    context,
                    icon: Icons.storage,
                    title: 'Advanced Databases',
                    subtitle: 'Graduate Level | 42 Students',
                    value: course2Enabled,
                    iconColor: Colors.orange,
                    onChanged: (val) {
                      setState(() => course2Enabled = val);
                      _showUpcomingFeature(context);
                    },
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  _buildCourseToggle(
                    context,
                    icon: Icons.psychology,
                    title: 'AI Ethics',
                    subtitle: 'Elective Seminar | 116 Students',
                    value: course3Enabled,
                    iconColor: Colors.lightBlue,
                    onChanged: (val) {
                      setState(() => course3Enabled = val);
                      _showUpcomingFeature(context);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            Text(
              '* Toggling access immediately revokes student submission capabilities for the specific course.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
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
                        side: WidgetStateProperty.all(BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            
            
            const SizedBox(height: 24),            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  await context.read<AuthProvider>().logout();
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    context.go('/');
                  }
                },
                icon: const Icon(Icons.logout, size: 24),
                label: Text(
                  l10n.logout,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // _buildMetricCard extracted to ProfStatsCard

  Widget _buildCourseToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? colorScheme.primary).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
