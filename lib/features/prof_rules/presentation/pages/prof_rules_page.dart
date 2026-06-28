import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';

class ProfRulesPage extends StatelessWidget {
  const ProfRulesPage({super.key});

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

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Gestión de Reglas de Exclusión',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Configure directivas estrictas para el motor de recuperación (RAG). Los dominios especificados aquí serán filtrados proactivamente antes de la generación de respuestas.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            
            // Añadir Regla Form
            Container(
              padding: const EdgeInsets.all(24),
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
                      Icon(Icons.add_circle_outline, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Añadir Regla',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Dominio o Concepto',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ej. Sistemas de Facturación, Redes Sociales...',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Razón de Exclusión (Opcional)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Justificación académica o técnica para el bloqueo...',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () => _showUpcomingFeature(context, l10n),
                      icon: const Icon(Icons.save),
                      label: Text(l10n.registerRule, style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.tertiary.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: colorScheme.tertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Efecto Inmediato',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Las reglas registradas impactan de inmediato el espacio vectorial. Las consultas de los estudiantes que infrinjan estas reglas serán rebotadas.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
