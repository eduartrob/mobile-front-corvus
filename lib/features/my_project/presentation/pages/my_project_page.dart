import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/widgets/corvus_top_bar.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';

import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

class MyProjectPage extends StatelessWidget {
  const MyProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyProjectProvider(),
      child: const _MyProjectPageContent(),
    );
  }
}

class _MyProjectPageContent extends StatefulWidget {
  const _MyProjectPageContent();

  @override
  State<_MyProjectPageContent> createState() => _MyProjectPageContentState();
}

class _MyProjectPageContentState extends State<_MyProjectPageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id ?? 'default_user';
      context.read<MyProjectProvider>().init(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<MyProjectProvider>();
    final userId = context.read<AuthProvider>().currentUser?.id ?? 'default_user';

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.state == ProjectState.detailedAnalysis 
                ? 'Análisis Detallado' 
                : 'Pre-validación de Propuesta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.state == ProjectState.detailedAnalysis 
                ? 'La IA ha evaluado tu manuscrito. Revisa las métricas clave y las recomendaciones para elevar la calidad de tu proyecto antes de la entrega final.'
                : 'Sube tu documento PDF. Nuestro motor de IA analizará tu propuesta contra los requerimientos académicos antes de la entrega final.',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            if (provider.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onErrorContainer),
                      onPressed: () => provider.reset(userId),
                    )
                  ],
                ),
              ),

            // Módulo de Carga (Estado Inicial)
            if (provider.state == ProjectState.initial || provider.state == ProjectState.error)
              _buildUploadZone(context, provider),

            // Archivo Cargado (Pre-validado o Analizando)
            if (provider.state != ProjectState.initial && provider.state != ProjectState.error && provider.selectedFile != null && provider.state != ProjectState.detailedAnalysis)
              _buildUploadedFileItem(context, provider),

            if (provider.state == ProjectState.uploading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Analizando estructura..."),
                    ],
                  ),
                ),
              ),

            if (provider.state == ProjectState.preValidated && provider.quickAnalysis != null)
              _buildFastRagAnalysis(context, provider.quickAnalysis!),

            if (provider.state == ProjectState.analyzing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Ollama evaluando la propuesta a fondo..."),
                    ],
                  ),
                ),
              ),

            if (provider.state == ProjectState.detailedAnalysis && provider.detailedAnalysis != null)
              _buildDetailedAnalysis(context, provider.detailedAnalysis!['ollama_analysis'] ?? {}),

            const SizedBox(height: 32),
            
            // Acciones Inferiores
            if (provider.state == ProjectState.preValidated) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => provider.reset(userId),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Eliminar Borrador',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => provider.submitForReview(userId),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Enviar para Revisión', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],

            if (provider.state == ProjectState.detailedAnalysis)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => provider.reset(userId),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Cargar otra propuesta',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ),
              
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadZone(BuildContext context, MyProjectProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 250),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.upload_file,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Arrastra tu propuesta PDF aquí',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tamaño máximo: 10MB. Formatos: PDF.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => provider.pickFile(context.read<AuthProvider>().currentUser?.id ?? ''),
            icon: const Icon(Icons.folder_open),
            label: const Text('Explorar Archivos'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              foregroundColor: colorScheme.onSurface,
              backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              side: BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedFileItem(BuildContext context, MyProjectProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.picture_as_pdf, color: colorScheme.error),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.fileName ?? 'documento.pdf',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.fileSize} • Subido hoy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (provider.state == ProjectState.preValidated)
            IconButton(
              onPressed: () => provider.reset(context.read<AuthProvider>().currentUser?.id ?? ''),
              icon: Icon(Icons.delete_outline, color: colorScheme.onSurfaceVariant),
              hoverColor: colorScheme.errorContainer,
            ),
        ],
      ),
    );
  }

  Widget _buildFastRagAnalysis(BuildContext context, Map<String, dynamic> data) {
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
          
          // Alineación Académica
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
          
          // Riesgo de Colisión
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
          
          // Áreas de Mejora
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

  Widget _buildDetailedAnalysis(BuildContext context, Map<String, dynamic> data) {
    final colorScheme = Theme.of(context).colorScheme;
    final innovationIndex = data['innovation_index'] ?? 0;
    final metrics = data['quality_metrics'] ?? {};
    final collisionRisk = data['collision_risk_assessment'] ?? 'No detectado';
    final recommendations = data['recommendations'] as List? ?? [];

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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.auto_awesome, color: colorScheme.secondary.withOpacity(0.5)),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.bar_chart, size: 24, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text('Métricas de Calidad', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 24),
              _buildMetricBar('Rigor Académico', metrics['academic_rigor_score'] ?? 0, colorScheme.primary, colorScheme),
              const SizedBox(height: 24),
              _buildMetricBar('Relevancia Técnica', metrics['technical_relevance_score'] ?? 0, colorScheme.secondary, colorScheme),
              const SizedBox(height: 24),
              _buildMetricBar('Claridad Estructural', metrics['structural_clarity_score'] ?? 0, colorScheme.tertiary, colorScheme),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Riesgo de colisión
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.error.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning, color: colorScheme.error),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riesgo de Colisión Semántica',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      collisionRisk,
                      style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant, height: 1.5),
                    ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: colorScheme.primaryContainer, size: 28),
                        const SizedBox(width: 12),
                        Text('Recomendaciones de la IA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${recommendations.length} Acciones',
                        style: TextStyle(fontSize: 12, color: colorScheme.primaryContainer, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...List.generate(recommendations.length, (index) {
                  final rec = recommendations[index];
                  // Obtener icono apropiado (ej: tips_and_updates)
                  IconData iconData = Icons.tips_and_updates;
                  if (rec['icon'] == 'lock') iconData = Icons.lock;
                  if (rec['icon'] == 'fact_check') iconData = Icons.fact_check;
                  if (rec['icon'] == 'library_books') iconData = Icons.library_books;
                  if (rec['icon'] == 'account_tree') iconData = Icons.account_tree;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(iconData, size: 24, color: colorScheme.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec['title'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: colorScheme.onSurface),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rec['description'] ?? '',
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, height: 1.4),
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
    if (score >= 90) return colorScheme.primaryContainer; // Azul oscuro
    if (score >= 70) return colorScheme.primary;
    if (score >= 50) return colorScheme.secondary; // Dorado/Amarillo
    return colorScheme.error;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excepcional';
    if (score >= 70) return 'Muy Bueno';
    if (score >= 50) return 'Aceptable';
    return 'Regular';
  }
}
