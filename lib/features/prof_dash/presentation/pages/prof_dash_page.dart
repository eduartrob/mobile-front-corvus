import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/corvus_top_bar.dart';
import 'package:mobile/shared/widgets/corvus_metric_card.dart';
import 'package:mobile/shared/widgets/corvus_progress_item.dart';
import 'package:mobile/shared/widgets/corvus_alert_item.dart';

class ProfDashPage extends StatelessWidget {
  const ProfDashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Metrics
            Row(
              children: [
                Expanded(
                  child: CorvusMetricCard(
                    label: 'EQUIPOS FORMADOS',
                    value: '12',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CorvusMetricCard(
                    label: 'PROPUESTAS LISTAS',
                    value: '8 de 12 equipos',
                    icon: Icons.description_outlined,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Avance General
            Container(
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
                      Icon(Icons.bar_chart, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Avance General',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CorvusProgressItem(
                    label: 'Fase de Investigación',
                    percentage: 85,
                  ),
                  const SizedBox(height: 16),
                  CorvusProgressItem(
                    label: 'Definición del RAG',
                    percentage: 60,
                  ),
                  const SizedBox(height: 16),
                  CorvusProgressItem(
                    label: 'Implementación Técnica',
                    percentage: 25,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Atención Requerida
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Atención Requerida',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CorvusAlertItem(
                    icon: Icons.error_outline,
                    iconColor: colorScheme.error,
                    text: 'Equipo Delta - Propuesta rechazada, requiere feedback.',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  CorvusAlertItem(
                    icon: Icons.info_outline,
                    iconColor: colorScheme.primary,
                    text: 'Revisión de pares - 3 equipos han completado la etapa.',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Ver todos los reportes'),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }
}
