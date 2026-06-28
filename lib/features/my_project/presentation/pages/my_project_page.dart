import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/my_project/presentation/widgets/upload_zone_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/uploaded_file_item_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/fast_rag_analysis_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/detailed_analysis_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/animated_loading_text_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/invalid_document_widget.dart';

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
    // Solo leemos el userId — no escuchamos todo AuthProvider en cada rebuild
    final userId = context.select<AuthProvider, String>(
      (a) => a.currentUser?.id ?? 'default_user',
    );

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: solo reacciona a cambios de ProjectState (no a fase/mensaje del server)
            _ProjectPageHeader(userId: userId),

            const SizedBox(height: 24),

            // CUERPO: RepaintBoundary aisla esta zona del header y el scroll
            RepaintBoundary(
              child: _ProjectPageBody(userId: userId),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// Solo reacciona a cambios de ProjectState. Cuando el polling cambia la
// fase (cada 2s) este widget NO se reconstruye.
// ─────────────────────────────────────────────────────────────────────────────
class _ProjectPageHeader extends StatelessWidget {
  final String userId;
  const _ProjectPageHeader({required this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    // context.select solo escucha el campo 'state'
    final state = context.select<MyProjectProvider, ProjectState>((p) => p.state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state == ProjectState.detailedAnalysis
              ? l10n.detailedAnalysisTitle
              : l10n.preValidationTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          state == ProjectState.detailedAnalysis
              ? l10n.detailedAnalysisDesc
              : l10n.preValidationDesc,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BODY
// Reacciona al provider completo porque necesita todos sus campos.
// Está aislado con RepaintBoundary: sus repaints no propagan hacia arriba.
// ─────────────────────────────────────────────────────────────────────────────
class _ProjectPageBody extends StatelessWidget {
  final String userId;
  const _ProjectPageBody({required this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<MyProjectProvider>();

    return Column(
      children: [
        // Error temporal del servidor
        if (provider.errorMessage != null && provider.documentTypeError == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colorScheme.errorContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onErrorContainer),
                  onPressed: () => provider.clearError(),
                )
              ],
            ),
          ),

        // Documento Inválido (Heurística)
        if (provider.documentTypeError != null)
          InvalidDocumentWidget(
            provider: provider,
            userId: userId,
            specificError: provider.documentTypeError!,
          ),

        // Módulo de Carga (Estado Inicial o Error de servidor)
        if (provider.state == ProjectState.initial ||
            (provider.state == ProjectState.error && provider.documentTypeError == null))
          UploadZoneWidget(provider: provider),

        // Archivo Cargado (Pre-validado o Analizando)
        if (provider.state != ProjectState.initial &&
            provider.state != ProjectState.error &&
            provider.selectedFile != null &&
            provider.state != ProjectState.detailedAnalysis)
          UploadedFileItemWidget(provider: provider),

        // Spinner de subida (pre-validación)
        if (provider.state == ProjectState.uploading)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.analyzingStructure),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => provider.cancelAnalysis(userId),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
              ],
            ),
          ),

        // Resultado de pre-validación
        if (provider.state == ProjectState.preValidated && provider.quickAnalysis != null)
          FastRagAnalysisWidget(data: provider.quickAnalysis!),

        // Análisis exhaustivo en curso
        // AnimatedLoadingTextWidget tiene su propio RepaintBoundary para aislar
        // sus repaints (que ocurren cada 2s) del botón de cancelar.
        if (provider.state == ProjectState.analyzing)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                const RepaintBoundary(child: AnimatedLoadingTextWidget()),
                const SizedBox(height: 48),
                OutlinedButton.icon(
                  onPressed: () => provider.cancelAnalysis(userId),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar Análisis'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
              ],
            ),
          ),

        // Resultado final del análisis
        if (provider.state == ProjectState.detailedAnalysis && provider.detailedAnalysis != null)
          DetailedAnalysisWidget(data: provider.detailedAnalysis!['ollama_analysis'] ?? {}),

        const SizedBox(height: 32),

        // Acciones inferiores (pre-validado)
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
                l10n.deleteDraft,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => provider.submitForReview(userId, l10n),
              icon: const Icon(Icons.send, size: 18),
              label: Text(l10n.sendForReview, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],

        // Acción: subir otra propuesta (análisis completado)
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
                l10n.uploadAnotherProposal,
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ),
      ],
    );
  }
}
