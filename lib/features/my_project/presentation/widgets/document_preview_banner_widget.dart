import 'package:flutter/material.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/my_project/presentation/pages/pdf_viewer_page.dart';

/// Abre el archivo PDF usando la librería nativa en la pantalla PDFViewerPage.
void openDocumentFile(BuildContext context, MyProjectProvider provider) {
  final file = provider.selectedFile;
  final fileName = provider.fileName ?? 'Propuesta_Proyecto.pdf';

  if (file != null && file.existsSync()) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(
          filePath: file.path,
          fileName: fileName,
        ),
      ),
    );
  } else {
    showDocumentViewerDialog(context, provider);
  }
}

/// Banner/Rectángulo de altura corta para previsualizar el documento completo cargado.
class DocumentPreviewBannerWidget extends StatelessWidget {
  final MyProjectProvider provider;

  const DocumentPreviewBannerWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileName = provider.fileName ?? 'propuesta_proyecto.pdf';
    final fileSize = provider.fileSize ?? 'PDF';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => openDocumentFile(context, provider),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.picture_as_pdf, color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 14, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Ver documento completo ($fileSize)',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.open_in_full, size: 16, color: colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Muestra un modal/diálogo interactivo con la previsualización y detalles del documento completo.
void showDocumentViewerDialog(BuildContext context, MyProjectProvider provider) {
  final colorScheme = Theme.of(context).colorScheme;
  final fileName = provider.fileName ?? 'Propuesta_Proyecto.pdf';
  final fileSize = provider.fileSize ?? 'PDF';
  final quickAnalysis = provider.quickAnalysis;
  final detailedAnalysis = provider.detailedAnalysis;

  final String? documentSummary = quickAnalysis?['summary'] ??
      quickAnalysis?['resumen'] ??
      detailedAnalysis?['ollama_analysis']?['summary'] ??
      detailedAnalysis?['ollama_analysis']?['verdict'];

  final List<dynamic>? structure = quickAnalysis?['estructura_detectada'] ??
      quickAnalysis?['structure'] ??
      detailedAnalysis?['ollama_analysis']?['sections'];

  showDialog(
    context: context,
    useSafeArea: true,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 650),
          child: Column(
            children: [
              // Encabezado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Documento Completo • $fileSize',
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Cuerpo con formato de hoja de lectura
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).brightness == Brightness.dark
                          ? colorScheme.surfaceContainerHighest
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.article_outlined, size: 18, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'VISTA PREVIA DE PROPUESTA',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        if (documentSummary != null && documentSummary.isNotEmpty) ...[
                          Text(
                            'Resumen / Contenido General:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            documentSummary,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (structure != null && structure.isNotEmpty) ...[
                          Text(
                            'Estructura y Secciones Detectadas:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...structure.map((item) {
                            final title = item is Map
                                ? (item['name'] ?? item['titulo'] ?? item['section'] ?? '')
                                : item.toString();
                            final desc = item is Map
                                ? (item['content'] ?? item['descripcion'] ?? '')
                                : '';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 16, color: colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (desc.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      desc,
                                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ] else ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                children: [
                                  Icon(Icons.picture_as_pdf, size: 48, color: colorScheme.primary.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  Text(
                                    fileName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'El documento PDF ha sido procesado exitosamente.\nPuedes revisar la propuesta completa y su análisis a continuación.',
                                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, height: 1.4),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Botones de Acción
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          openDocumentFile(context, provider);
                        },
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Abrir en lector de archivos del sistema'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
