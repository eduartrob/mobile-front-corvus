import 'package:flutter/material.dart';

class FastRagAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const FastRagAnalysisWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alignment = (data['academic_alignment'] ?? 0) / 100.0;
    final collision = (data['collision_risk_pct'] ?? 0) / 100.0;
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: colorScheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Análisis RAG Rápido',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Procesado',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.fact_check_outlined, size: 16, color: colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Text(
                    'Alineación Académica', 
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: colorScheme.onSurface),
                  ),
                ],
              ),
              Text('${(alignment * 100).toInt()}%', style: TextStyle(color: colorScheme.tertiary, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: alignment,
              backgroundColor: colorScheme.surfaceContainer,
              color: colorScheme.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estructura básica validada contra los lineamientos.',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.plagiarism_outlined, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Riesgo de Colisión', 
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: colorScheme.onSurface),
                  ),
                ],
              ),
              Text('${data['collision_risk_level']} (${(collision * 100).toInt()}%)', 
                style: TextStyle(color: colorScheme.tertiary, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: collision,
              backgroundColor: colorScheme.surfaceContainer,
              color: colorScheme.tertiary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Similitudes encontradas en la base de datos local.',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          
          const SizedBox(height: 24),
          
          if (data['areas_of_improvement'] != null && (data['areas_of_improvement'] as List).isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ÁREAS DE MEJORA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate((data['areas_of_improvement'] as List).length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.edit_note, size: 18, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              data['areas_of_improvement'][index].toString(),
                              style: TextStyle(fontSize: 14, color: colorScheme.onSurface, height: 1.4),
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
      ),
    );
  }
}
