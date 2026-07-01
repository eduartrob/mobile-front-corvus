import 'package:flutter/material.dart';
import 'package:mobile/features/inspiration/presentation/widgets/glass_container.dart';

class SugerenciaCard extends StatelessWidget {
  final Map<String, dynamic> sugerencia;

  const SugerenciaCard({super.key, required this.sugerencia});

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
                      color: colorScheme.primary.withValues(alpha: 0.1),
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
