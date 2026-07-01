import 'package:flutter/material.dart';
import 'innovation_card.dart';
import 'metrics_card.dart';
import 'risk_card.dart';
class DetailedAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailedAnalysisWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
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



    return Column(
      children: [
        InnovationCard(innovationIndex: innovationIndex),
        
        const SizedBox(height: 12),
        
        MetricsCard(metrics: metrics),
        
        const SizedBox(height: 12),
        
        RiskCard(collisionRisk: collisionRisk, collisionExplanation: collisionExplanation),
        
        const SizedBox(height: 12),
        
        if (recommendations.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.psychology, color: colorScheme.primary, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Recomendaciones IA', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
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
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
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

}
