import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_version.dart';

class AppUpdatePage extends StatelessWidget {
  const AppUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualización de la aplicación', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.system_update, size: 80, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Corvus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versión ${AppVersion.version}',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historial de versiones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVersionItem(
                    context, 
                    'v2.5.4 (Actual)', 
                    'Implementacion de doble verificacion en acciones de docentes, rediseño de tarjetas de edicion, busqueda de docentes y mejoras en alertas de salida.',
                  ),
                  const Divider(),
                  _buildVersionItem(
                    context, 
                    'v2.5.2', 
                    'Mejoras visuales en alertas de evaluación, optimización en extracción de títulos y correcciones en la lista de docentes.',
                  ),
                  const Divider(),
                  _buildVersionItem(
                    context, 
                    'v1.2.12', 
                    'Se refactorizó el perfil de usuario con un nuevo diseño y opciones de edición más fluidas.',
                  ),
                  const Divider(),
                  _buildVersionItem(
                    context, 
                    'v1.2.11', 
                    'Correcciones menores en validación de correos y experiencia de inicio de sesión.',
                  ),
                  const Divider(),
                  _buildVersionItem(
                    context, 
                    'v1.2.0', 
                    'Implementación del sistema RAG Core Engine y soporte para múltiples fuentes de documentos.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Text(
              '© 2026 Corvus. Todos los derechos reservados.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionItem(BuildContext context, String version, String description) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            version,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
