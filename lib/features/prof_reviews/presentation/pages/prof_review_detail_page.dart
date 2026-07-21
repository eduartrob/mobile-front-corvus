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
  void _updateStatus(
    String status, 
    {
      String? appointmentDate, 
      String? reason,
      bool isEditAppointment = false,
      bool isCancelAppointment = false,
    }
  ) async {
    final provider = context.read<ProfReviewsProvider>();
    final success = await provider.updateStatus(
      widget.review.id, 
      status, 
      appointmentDate: appointmentDate,
      reason: reason,
      isEditAppointment: isEditAppointment,
      isCancelAppointment: isCancelAppointment,
    );
    if (success && mounted) {
      final String msg = isCancelAppointment
          ? 'Cita cancelada exitosamente'
          : isEditAppointment
              ? 'Cita modificada exitosamente'
              : 'Revisión actualizada: ${_getTranslatedStatus(status)}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg))
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
    final isApprove = status == 'APPROVED';
    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            isApprove ? '¿Aprobar proyecto?' : '¿Rechazar proyecto?',
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isApprove 
                  ? '¿Estás seguro de que deseas aprobar esta propuesta de proyecto?' 
                  : '¿Estás seguro de que deseas rechazar esta propuesta de proyecto?',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Motivo o retroalimentación (opcional)',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: Text('CANCELAR', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isApprove ? colorScheme.primary : colorScheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _evaluateProject(isApprove, reasonController.text);
              },
              child: Text('CONFIRMAR', style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  void _showCancelAppointmentDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            '¿Cancelar cita programada?',
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            '¿Estás seguro de que deseas cancelar la cita con el equipo? Se enviará una notificación directa a los integrantes.',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('VOLVER', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus('PENDING', appointmentDate: null, isCancelAppointment: true);
              },
              child: const Text('CONFIRMAR CANCELACIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  void _showSummonDialog(AppLocalizations l10n, {bool isEdit = false}) {
    DateTime? selectedDate = (isEdit && widget.review.appointmentDate != null)
        ? widget.review.appointmentDate!.toLocal()
        : null;
    TimeOfDay? selectedTime = (isEdit && widget.review.appointmentDate != null)
        ? TimeOfDay.fromDateTime(widget.review.appointmentDate!.toLocal())
        : null;

    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Text(
                isEdit ? 'Editar Cita' : l10n.citeTeam,
                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit
                        ? 'Modifica la fecha y hora programada para la cita.'
                        : 'Selecciona la fecha y hora para la defensa del proyecto.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(selectedDate == null ? 'Seleccionar Fecha' : DateFormat('dd/MM/yyyy').format(selectedDate!), style: const TextStyle(fontWeight: FontWeight.w500)),
                          trailing: Icon(Icons.calendar_today, color: colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onTap: () async {
                            DateTime initial = selectedDate ?? DateTime.now().add(const Duration(days: 1));
                            while (initial.weekday > 5) {
                              initial = initial.add(const Duration(days: 1));
                            }
                            
                            final d = await showDatePicker(
                              context: context,
                              initialDate: initial,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 60)),
                              selectableDayPredicate: (DateTime val) => val.weekday >= 1 && val.weekday <= 5,
                            );
                            if (d != null) setState(() => selectedDate = d);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(selectedTime == null ? 'Seleccionar Hora' : selectedTime!.format(context), style: const TextStyle(fontWeight: FontWeight.w500)),
                          trailing: Icon(Icons.access_time, color: colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? const TimeOfDay(hour: 8, minute: 0),
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
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel.toUpperCase(), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (selectedDate != null && selectedTime != null) {
                      final finalDt = DateTime(
                        selectedDate!.year, selectedDate!.month, selectedDate!.day,
                        selectedTime!.hour, selectedTime!.minute
                      );
                      Navigator.pop(ctx);
                      _updateStatus(
                        'SUMMONED', 
                        appointmentDate: finalDt.toUtc().toIso8601String(),
                        isEditAppointment: isEdit,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor selecciona fecha y hora'))
                      );
                    }
                  },
                  child: Text(isEdit ? 'GUARDAR CITA' : l10n.citeTeam.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showDefenseChatHistory(BuildContext context, List<dynamic> history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final colors = Theme.of(context).colorScheme;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Historial de Defensa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final msg = history[index];
                      final isUser = msg['role'] == 'user';
                      final isSystem = msg['role'] == 'system';
                      if (isSystem) return const SizedBox.shrink();

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser ? colors.primaryContainer : colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                              bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            msg['content']?.toString() ?? '',
                            style: TextStyle(
                              color: isUser ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
      final List<String> textsToSearch = [];
      if (ollamaAnalysis['verdict'] != null) textsToSearch.add(ollamaAnalysis['verdict']);
      if (ollamaAnalysis['semantic_collision_risk']?['explanation'] != null) {
        textsToSearch.add(ollamaAnalysis['semantic_collision_risk']['explanation']);
      }
      if (data['defense_chat_history'] != null) {
         final chatList = data['defense_chat_history'] as List<dynamic>;
         final firstMsg = chatList.firstWhere((m) => m['role'] == 'assistant' || m['role'] == 'system', orElse: () => null);
         if (firstMsg != null && firstMsg['content'] != null) {
           textsToSearch.add(firstMsg['content'].toString());
         }
      }

      final regex = RegExp(r"(?:proyecto|propuesta)(?:\s+de)?\s+'([^']+)'", caseSensitive: false);
      for (final text in textsToSearch) {
        final match = regex.firstMatch(text);
        if (match != null && match.groupCount >= 1) {
          extractedProjectName = match.group(1);
          break;
        }
      }
    }
    
    String fallbackName = data['file_name']?.toString().replaceAll('.pdf', '') ?? 'Propuesta sin título';
    if (fallbackName.startsWith('draft_') || fallbackName.startsWith('propuesta_')) {
      fallbackName = 'Propuesta de Proyecto';
    }
    final projectName = extractedProjectName ?? fallbackName;
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
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_calendar, color: Colors.orange),
                          tooltip: 'Editar Cita',
                          onPressed: () => _showSummonDialog(l10n, isEdit: true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.event_busy, color: Colors.red),
                          tooltip: 'Cancelar Cita',
                          onPressed: () => _showCancelAppointmentDialog(),
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
                
                if (data['defense_chat_history'] != null && (data['defense_chat_history'] as List).isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDefenseChatHistory(context, data['defense_chat_history'] as List<dynamic>),
                      icon: const Icon(Icons.forum),
                      label: const Text('Ver Chat de Defensa', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
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
          
          if (widget.review.status == 'PENDING' || widget.review.status == 'APPROVED' || widget.review.status == 'SUMMONED')
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
                    if (widget.review.status == 'SUMMONED') ...[
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: OutlinedButton.icon(
                                onPressed: () => _showSummonDialog(l10n, isEdit: true),
                                icon: const Icon(Icons.edit_calendar),
                                label: const Text('Editar Cita'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: colorScheme.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: OutlinedButton.icon(
                                onPressed: () => _showCancelAppointmentDialog(),
                                icon: const Icon(Icons.event_busy),
                                label: const Text('Cancelar Cita'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.error,
                                  side: BorderSide(color: colorScheme.error),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
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
                      const SizedBox(height: 12),
                    ],
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}
