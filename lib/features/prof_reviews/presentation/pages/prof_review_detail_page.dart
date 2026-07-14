import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/prof_reviews/presentation/provider/prof_reviews_provider.dart';
import 'package:mobile/features/prof_reviews/data/models/final_review_model.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/my_project/presentation/widgets/detailed_analysis_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfReviewDetailPage extends StatefulWidget {
  final FinalReviewModel review;

  const ProfReviewDetailPage({super.key, required this.review});

  @override
  State<ProfReviewDetailPage> createState() => _ProfReviewDetailPageState();
}

class _ProfReviewDetailPageState extends State<ProfReviewDetailPage> {
  void _updateStatus(String status, {String? appointmentDate, String? reason}) async {
    final provider = context.read<ProfReviewsProvider>();
    final success = await provider.updateStatus(
      widget.review.id, 
      status, 
      appointmentDate: appointmentDate,
      reason: reason
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Revisión actualizada: ${_getTranslatedStatus(status)}'))
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error al actualizar'))
      );
    }
  }

  void _evaluateProject(bool isApproved, String comment) async {
    final provider = context.read<ProfReviewsProvider>();
    final success = await provider.evaluateProject(
      widget.review.id, 
      comment, 
      isApproved
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evaluación registrada exitosamente'))
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error al registrar evaluación'))
      );
    }
  }

  void _showReasonDialog(String status) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(status == 'APPROVED' ? 'Motivo de Aprobación' : 'Motivo de Rechazo'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Ingresa el motivo (opcional)',
              border: OutlineInputBorder()
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _evaluateProject(status == 'APPROVED', reasonController.text);
              },
              child: const Text('Confirmar')
            )
          ],
        );
      }
    );
  }

  void _showSummonDialog(AppLocalizations l10n) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.citeTeam),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(selectedDate == null ? 'Seleccionar Fecha' : DateFormat('dd/MM/yyyy').format(selectedDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime nextWeekday = DateTime.now().add(const Duration(days: 1));
                      while (nextWeekday.weekday > 5) {
                        nextWeekday = nextWeekday.add(const Duration(days: 1));
                      }
                      
                      final d = await showDatePicker(
                        context: context,
                        initialDate: nextWeekday,
                        firstDate: nextWeekday,
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                        selectableDayPredicate: (DateTime val) => val.weekday >= 1 && val.weekday <= 5,
                      );
                      if (d != null) setState(() => selectedDate = d);
                    },
                  ),
                  ListTile(
                    title: Text(selectedTime == null ? 'Seleccionar Hora' : selectedTime!.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (t != null) {
                        if (t.hour >= 8 && (t.hour < 16 || (t.hour == 16 && t.minute == 0))) {
                          setState(() => selectedTime = t);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('La hora debe ser entre 8:00 AM y 4:00 PM'))
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDate != null && selectedTime != null) {
                      final finalDt = DateTime(
                        selectedDate!.year, selectedDate!.month, selectedDate!.day,
                        selectedTime!.hour, selectedTime!.minute
                      );
                      Navigator.pop(ctx);
                      _updateStatus('SUMMONED', appointmentDate: finalDt.toUtc().toIso8601String());
                    }
                  },
                  child: const Text('Citar Equipo'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  String _getTranslatedStatus(String status) {
    switch (status) {
      case 'PENDING': return 'PENDIENTE';
      case 'APPROVED': return 'APROBADA';
      case 'REJECTED': return 'RECHAZADA';
      case 'SUMMONED': return 'CITADA';
      default: return status;
    }
  }

  Color _getStatusBgColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'PENDING': return colorScheme.tertiaryContainer;
      case 'APPROVED': return Colors.green.withOpacity(0.2);
      case 'REJECTED': return Colors.red.withOpacity(0.2);
      case 'SUMMONED': return Colors.orange.withOpacity(0.2);
      default: return colorScheme.surfaceContainerHighest;
    }
  }

  Color _getStatusTextColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'PENDING': return colorScheme.onTertiaryContainer;
      case 'APPROVED': return Colors.green.shade800;
      case 'REJECTED': return Colors.red.shade800;
      case 'SUMMONED': return Colors.orange.shade800;
      default: return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final data = widget.review.proposalData;
    final aiAnalysis = data['ai_analysis'] as Map<String, dynamic>? ?? {};
    final ollamaAnalysis = aiAnalysis['ollama_analysis'] as Map<String, dynamic>? ?? {};
    final teamInfo = data['team_info'] as Map<String, dynamic>? ?? {};
    
    // Try to extract project name from verdict or explanation (e.g. "El proyecto 'Pulmones Urbanos'...")
    String? extractedProjectName = ollamaAnalysis['projectName'] ?? ollamaAnalysis['title'];
    if (extractedProjectName == null) {
      final textWithProjectName = (ollamaAnalysis['verdict'] as String?) ?? (ollamaAnalysis['semantic_collision_risk']?['explanation'] as String?);
      if (textWithProjectName != null) {
        final match = RegExp(r"El proyecto '([^']+)'").firstMatch(textWithProjectName);
        if (match != null && match.groupCount >= 1) {
          extractedProjectName = match.group(1);
        }
      }
    }
    
    final projectName = extractedProjectName ?? data['file_name']?.toString().replaceAll('.pdf', '') ?? 'Propuesta sin título';
    final teamName = teamInfo['name'] ?? 'Equipo sin nombre';
    final membersList = teamInfo['members'] as List<dynamic>? ?? [];
    final fileName = data['file_name'] ?? 'documento.pdf';
    final fileUrl = data['file_url'] as String?;
    final dateStr = DateFormat('dd MMM yyyy').format(widget.review.createdAt);

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(widget.review.status, colorScheme),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTranslatedStatus(widget.review.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusTextColor(widget.review.status, colorScheme),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Enviado: $dateStr',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  projectName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Mostrar nombre del equipo e integrantes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.group, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Equipo: $teamName',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Integrantes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      if (membersList.isEmpty)
                         Text('No hay integrantes registrados', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14))
                      else
                         ...membersList.map((m) => Padding(
                           padding: const EdgeInsets.only(bottom: 4),
                           child: Row(
                             children: [
                               const Icon(Icons.person_outline, size: 16),
                               const SizedBox(width: 8),
                               Expanded(child: Text(m.toString(), style: const TextStyle(fontSize: 14))),
                             ],
                           ),
                         )),
                    ],
                  ),
                ),
                
                if (widget.review.status == 'SUMMONED' && widget.review.appointmentDate != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cita Programada',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd/MM/yyyy hh:mm a').format(widget.review.appointmentDate!.toLocal()),
                                style: TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                
                // Mostrar archivo subido
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: fileUrl != null ? () async {
                      final uri = Uri.parse(fileUrl);
                      try {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se pudo abrir el archivo')),
                          );
                        }
                      }
                    } : null,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: fileUrl != null ? colorScheme.primary.withValues(alpha: 0.5) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.description, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Propuesta subida:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  fileName, 
                                  style: TextStyle(
                                    color: fileUrl != null ? colorScheme.primary : colorScheme.onSurfaceVariant, 
                                    fontSize: 14,
                                    decoration: fileUrl != null ? TextDecoration.underline : null,
                                  )
                                ),
                              ],
                            ),
                          ),
                          if (fileUrl != null)
                            Icon(Icons.open_in_new, color: colorScheme.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Análisis Detallado de IA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                DetailedAnalysisWidget(data: ollamaAnalysis),
                
                const SizedBox(height: 150),
              ],
            ),
          ),
          
          if (widget.review.status == 'PENDING' || widget.review.status == 'APPROVED')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton.icon(
                        onPressed: () => _showSummonDialog(l10n),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text(l10n.citeTeam),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    if (widget.review.status == 'PENDING') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () => _showReasonDialog('REJECTED'),
                                icon: const Icon(Icons.close),
                                label: Text(l10n.reject),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.error,
                                  foregroundColor: colorScheme.onError,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () => _showReasonDialog('APPROVED'),
                                icon: const Icon(Icons.check),
                                label: Text(l10n.approve),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
