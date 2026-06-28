import 'package:flutter/material.dart';

class DetailedAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailedAnalysisWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Imprimir el JSON para debug
    debugPrint("--- JSON DEL LLM ---");
    debugPrint(data.toString());
    debugPrint("--------------------");

    final colorScheme = Theme.of(context).colorScheme;
    
    final rawInnovation = data['innovation_index'];
    final int innovationIndex = rawInnovation is Map 
        ? (rawInnovation['score'] is num ? (rawInnovation['score'] as num).toInt() : int.tryParse(rawInnovation['score'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        : (rawInnovation is num ? rawInnovation.toInt() : int.tryParse(rawInnovation?.toString() ?? '0') ?? 0);
        
    final metrics = data['quality_metrics'] ?? {};
    final collisionRiskObj = data['semantic_collision_risk'];
    final collisionRisk = collisionRiskObj is Map ? (collisionRiskObj['alert_type'] ?? 'No detectado') : (data['collision_risk_assessment'] ?? 'No detectado');
    final String collisionExplanation = collisionRiskObj is Map ? (collisionRiskObj['explanation'] ?? '') : '';
    final recommendations = data['recommendations'] as List? ?? [];

    Color riskColor = colorScheme.error;
    Color riskBgColor = colorScheme.errorContainer.withOpacity(0.5);
    IconData riskIcon = Icons.warning;

    final riskLower = collisionRisk.toLowerCase();
    if (riskLower.contains('falsa alarma') || riskLower.contains('bajo')) {
      riskColor = Colors.green.shade700;
      riskBgColor = Colors.green.shade100;
      riskIcon = Icons.verified_user_outlined;
    } else if (riskLower.contains('medio')) {
      riskColor = Colors.orange.shade800;
      riskBgColor = Colors.orange.shade100;
      riskIcon = Icons.info_outline;
    } else if (riskLower.contains('no detectado')) {
      riskColor = colorScheme.primary;
      riskBgColor = colorScheme.primaryContainer.withOpacity(0.3);
      riskIcon = Icons.shield_outlined;
    }

    return Column(
      children: [
        // Índice de Innovación
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Índice de Innovación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.auto_awesome, size: 18, color: colorScheme.secondary.withOpacity(0.8)),
                ],
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: CircularProgressIndicator(
                      value: innovationIndex / 100.0,
                      strokeWidth: 12,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: _getScoreColor(innovationIndex, colorScheme),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$innovationIndex',
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: colorScheme.onSurface, height: 1),
                          ),
                          Text(
                            '%',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getScoreLabel(innovationIndex),
                        style: TextStyle(
                          fontSize: 12, 
                          color: _getScoreColor(innovationIndex, colorScheme),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Métricas de Calidad
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Icon(Icons.bar_chart, size: 18, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text('Métricas de Calidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 24),
              _buildMetricBar('Rigor Académico', (metrics['academic_rigor'] ?? metrics['academic_rigor_score'] ?? 0) as int, colorScheme.primary, colorScheme),
              const SizedBox(height: 24),
              _buildMetricBar('Relevancia Técnica', (metrics['technical_relevance'] ?? metrics['technical_relevance_score'] ?? 0) as int, colorScheme.secondary, colorScheme),
              const SizedBox(height: 24),
              _buildMetricBar('Claridad Estructural', (metrics['structural_clarity'] ?? metrics['structural_clarity_score'] ?? 0) as int, colorScheme.tertiary, colorScheme),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Riesgo de colisión
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: riskBgColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: riskColor.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: riskBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(riskIcon, size: 20, color: riskColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riesgo: $collisionRisk',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: riskColor),
                    ),
                    if (collisionExplanation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        collisionExplanation,
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, height: 1.5),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Recomendaciones
        if (recommendations.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: colorScheme.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Recomendaciones IA', 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${recommendations.length} Acciones',
                          style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(recommendations.length, (index) {
                  final rec = recommendations[index];
                  IconData iconData = Icons.tips_and_updates;
                  if (rec['icon'] == 'lock') iconData = Icons.lock;
                  if (rec['icon'] == 'fact_check') iconData = Icons.fact_check;
                  if (rec['icon'] == 'library_books') iconData = Icons.library_books;
                  if (rec['icon'] == 'account_tree') iconData = Icons.account_tree;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Icon(iconData, size: 22, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec['title'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                rec['description'] ?? '',
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, height: 1.45),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                })
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetricBar(String label, int value, Color color, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant)),
            Text('$value%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100.0,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score, ColorScheme colorScheme) {
    if (score >= 90) return colorScheme.primaryContainer; 
    if (score >= 70) return colorScheme.primary;
    if (score >= 50) return colorScheme.secondary; 
    return colorScheme.error;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excepcional';
    if (score >= 70) return 'Muy Bueno';
    if (score >= 50) return 'Aceptable';
    return 'Regular';
  }
}
