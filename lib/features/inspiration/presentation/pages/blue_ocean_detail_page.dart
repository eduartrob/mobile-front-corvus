import 'package:flutter/material.dart';
import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';
import 'package:mobile/features/inspiration/presentation/widgets/glass_container.dart';
import 'package:mobile/features/inspiration/presentation/widgets/sugerencias_card.dart';
import 'package:mobile/features/inspiration/presentation/widgets/blue_ocean_header.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/providers/saved_projects_provider.dart';

class BlueOceanDetailPage extends StatelessWidget {
  final ProjectEntity project;

  const BlueOceanDetailPage({super.key, required this.project});

  int _parseMetricValue(dynamic metricVal) {
    if (metricVal == null) return 0;
    if (metricVal is int) return metricVal;
    if (metricVal is double) return metricVal.toInt();
    if (metricVal is num) return metricVal.toInt();
    if (metricVal is String) {
      return int.tryParse(metricVal.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    if (metricVal is Map) {
      final val = metricVal['score'] ?? metricVal['valor'] ?? metricVal['porcentaje'] ?? metricVal['value'] ?? metricVal['puntuacion'] ?? metricVal['promedio'];
      return _parseMetricValue(val);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final savedProjectsProvider = context.watch<SavedProjectsProvider>();
    final isSaved = savedProjectsProvider.isSaved(project.id);
    
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final analysis = project.analysisData ?? {};
    
    final hallazgo = isEn 
        ? (analysis['hallazgo_principal_en'] ?? analysis['hallazgo_principal'] ?? 'Could not load the main finding.')
        : (analysis['hallazgo_principal_es'] ?? analysis['hallazgo_principal'] ?? 'No se pudo cargar el hallazgo principal.');
        
    final sugerencias = isEn
        ? ((analysis['sugerencias_en'] as List<dynamic>?) ?? (analysis['sugerencias'] as List<dynamic>?) ?? [])
        : ((analysis['sugerencias_es'] as List<dynamic>?) ?? (analysis['sugerencias'] as List<dynamic>?) ?? []);
        
    final metricas = (analysis['metricas'] as Map<String, dynamic>?) ?? {};

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isEn ? 'Blue Ocean Analysis' : 'Análisis de Océano Azul', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: colorScheme.secondary),
                const SizedBox(width: 4),
                Text(isEn ? 'AI Generated' : 'AI Generado', style: TextStyle(fontSize: 12, color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              isEn 
                ? 'Strategic evaluation of feasibility and originality for a potential thesis topic or research project based on ${project.category.toLowerCase()}.'
                : 'Evaluación estratégica de viabilidad y originalidad para un potencial tema de tesis o proyecto de investigación basado en ${project.category.toLowerCase()}.',
              style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 24),

            BlueOceanSectionTitle(title: isEn ? 'Main Finding' : 'Hallazgo Principal', icon: Icons.insights, color: colorScheme.secondary),
            GlassContainer(
              blur: 0,
              opacity: 0.5,
              padding: const EdgeInsets.all(20),
              child: Text(
                hallazgo,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ),
            const SizedBox(height: 24),

            BlueOceanSectionTitle(title: isEn ? 'Methodological Suggestions' : 'Sugerencias de Abordaje Metodológico', icon: Icons.schema_outlined, color: colorScheme.primary),
            if (sugerencias.isEmpty)
              Text(isEn ? 'No suggestions available.' : 'Sin sugerencias disponibles.')
            else
              ...sugerencias.map((s) => SugerenciaCard(sugerencia: s)),
            
            const SizedBox(height: 24),

            GlassContainer(
              blur: 0,
              opacity: 0.5,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? 'FEASIBILITY METRICS' : 'MÉTRICAS DE VIABILIDAD',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 20),
                  FeasibilityMetricBar(
                    label: isEn ? 'Originality' : 'Originalidad',
                    value: _parseMetricValue(metricas['originalidad']),
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  FeasibilityMetricBar(
                    label: isEn ? 'Data Availability' : 'Disponibilidad de Datos',
                    value: _parseMetricValue(metricas['disponibilidad_datos']),
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  FeasibilityMetricBar(
                    label: isEn ? 'Academic Relevance' : 'Relevancia Académica',
                    value: _parseMetricValue(metricas['relevancia_academica']),
                    color: colorScheme.tertiary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),


            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<SavedProjectsProvider>().toggleSave(project);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSaved ? 'Removido de guardados' : 'Guardado para después'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border, 
                  color: colorScheme.primary
                ),
                label: Text(
                  isSaved 
                    ? (isEn ? 'Saved' : 'Guardado') 
                    : (isEn ? 'Save for later' : 'Guardar para después'), 
                  style: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w600)
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: isSaved ? colorScheme.primary.withValues(alpha: 0.1) : null,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


