import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/widgets/corvus_top_bar.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/my_project/presentation/widgets/upload_zone_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/uploaded_file_item_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/fast_rag_analysis_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/detailed_analysis_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/animated_loading_text_widget.dart';

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
              UploadZoneWidget(provider: provider),

            // Archivo Cargado (Pre-validado o Analizando)
            if (provider.state != ProjectState.initial && provider.state != ProjectState.error && provider.selectedFile != null && provider.state != ProjectState.detailedAnalysis)
              UploadedFileItemWidget(provider: provider),

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
              FastRagAnalysisWidget(data: provider.quickAnalysis!),

            if (provider.state == ProjectState.analyzing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 24),
                      AnimatedLoadingTextWidget(),
                    ],
                  ),
                ),
              ),

            if (provider.state == ProjectState.detailedAnalysis && provider.detailedAnalysis != null)
              DetailedAnalysisWidget(data: provider.detailedAnalysis!['ollama_analysis'] ?? {}),

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
}

