import 'package:flutter/material.dart';
import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';
import 'package:mobile/features/inspiration/presentation/widgets/glass_container.dart';
import 'package:mobile/l10n/app_localizations.dart';

class BlueOceanDetailPage extends StatelessWidget {
  final ProjectEntity project;

  const BlueOceanDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    // Extraer datos del análisis (si los hay)
    final analysis = project.analysisData ?? {};
    
    // Lógica de fallback para JSON anterior (solo 'hallazgo_principal') y JSON bilingüe
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
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(isEn ? 'AI Generated' : 'AI Generado', style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.w600)),
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
            // ── Título Principal ──
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

            // ── 1. Hallazgo Principal ──
            _SectionTitle(title: isEn ? 'Main Finding' : 'Hallazgo Principal', icon: Icons.insights, color: Colors.orange),
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

            // ── 2. Sugerencias Metodológicas ──
            _SectionTitle(title: isEn ? 'Methodological Suggestions' : 'Sugerencias de Abordaje Metodológico', icon: Icons.schema_outlined, color: Colors.blue),
            if (sugerencias.isEmpty)
              Text(isEn ? 'No suggestions available.' : 'Sin sugerencias disponibles.')
            else
              ...sugerencias.map((s) => _SugerenciaCard(sugerencia: s)),
            
            const SizedBox(height: 24),

            // ── 3. Métricas de Viabilidad ──
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
                  _MetricBar(
                    label: isEn ? 'Originality' : 'Originalidad',
                    value: metricas['originalidad'] ?? 0,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _MetricBar(
                    label: isEn ? 'Data Availability' : 'Disponibilidad de Datos',
                    value: metricas['disponibilidad_datos'] ?? 0,
                    color: Colors.brown,
                  ),
                  const SizedBox(height: 16),
                  _MetricBar(
                    label: isEn ? 'Academic Relevance' : 'Relevancia Académica',
                    value: metricas['relevancia_academica'] ?? 0,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── 4. Botones de Acción ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showComingSoon(context, l10n),
                icon: const Icon(Icons.rocket_launch, color: Colors.white),
                label: Text(isEn ? 'Use this idea' : 'Usar esta idea', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showComingSoon(context, l10n),
                icon: Icon(Icons.bookmark_border, color: colorScheme.primary),
                label: Text(isEn ? 'Save for later' : 'Guardar para después', style: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureUpcoming),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS AUXILIARES
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionTitle({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SugerenciaCard extends StatelessWidget {
  final Map<String, dynamic> sugerencia;

  const _SugerenciaCard({required this.sugerencia});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRecomendado = sugerencia['tipo'] == 'Recomendado';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        blur: 0,
        opacity: 0.3,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    sugerencia['titulo'] ?? '',
                    style: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.bold,
                      color: isRecomendado ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isRecomendado)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Recomendado',
                      style: TextStyle(fontSize: 10, color: colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sugerencia['descripcion'] ?? '',
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MetricBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('$value%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (value / 100).clamp(0.0, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
