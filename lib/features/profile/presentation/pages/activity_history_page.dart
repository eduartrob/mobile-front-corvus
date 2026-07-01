import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import '../widgets/activity_item_widget.dart';

class ActivityHistoryPage extends StatelessWidget {
  const ActivityHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // TODO: Fetch this from backend when endpoint is available.
    // Using mock data for now as requested.
    final List<Map<String, dynamic>> mockActivities = [
      {
        'icon': Icons.update,
        'title': l10n.ragEngineUpdate,
        'time': 'Hace 2 horas',
      },
      {
        'icon': Icons.menu_book,
        'title': l10n.readingCompleted,
        'time': 'Ayer',
      },
      {
        'icon': Icons.login,
        'title': 'Inicio de sesión desde dispositivo nuevo',
        'time': 'Hace 3 días',
      },
      {
        'icon': Icons.analytics,
        'title': 'Análisis de viabilidad completado: "Optimización de Algoritmos RAG"',
        'time': 'Hace 5 días',
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Sincronización con Google Drive completada',
        'time': 'Hace 1 semana',
      },
      {
        'icon': Icons.group_add,
        'title': 'Invitación al equipo de investigación aceptada',
        'time': 'Hace 2 semanas',
      },
      {
        'icon': Icons.settings_backup_restore,
        'title': 'Recuperación de análisis en segundo plano completada',
        'time': 'Hace 2 semanas',
      },
      {
        'icon': Icons.check_circle_outline,
        'title': 'Perfil completado al 100%',
        'time': 'Hace 1 mes',
      },
      {
        'icon': Icons.fiber_new,
        'title': 'Bienvenido a Corvus',
        'time': 'Hace 1 mes',
      },
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Historial de Actividad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: mockActivities.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),
        itemBuilder: (context, index) {
          final activity = mockActivities[index];
          return ActivityItemWidget(
            icon: activity['icon'],
            title: activity['title'],
            time: activity['time'],
          );
        },
      ),
    );
  }
}
