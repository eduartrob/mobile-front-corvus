import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/prof_reviews/presentation/provider/prof_reviews_provider.dart';
import 'package:mobile/features/prof_reviews/presentation/pages/prof_review_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:mobile/shared/widgets/corvus_skeleton.dart';

class ProfReviewsPage extends StatefulWidget {
  final String projectId;
  const ProfReviewsPage({super.key, required this.projectId});

  @override
  State<ProfReviewsPage> createState() => _ProfReviewsPageState();
}

class _ProfReviewsPageState extends State<ProfReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfReviewsProvider>().fetchReviews(projectId: widget.projectId);
    });
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
    final provider = context.watch<ProfReviewsProvider>();
    final reviews = provider.reviews;

    return Scaffold(
      appBar: const CorvusTopBar(showBackButton: false),
      body: (provider.isLoading && provider.reviews.isEmpty)
          ? ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, __) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          CorvusSkeleton(height: 18, width: 80),
                          CorvusSkeleton(height: 14, width: 60),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const CorvusSkeleton(height: 22, width: 200),
                      const SizedBox(height: 8),
                      const CorvusSkeleton(height: 16, width: 140),
                      const SizedBox(height: 8),
                      const CorvusSkeleton(height: 14, width: 250),
                    ],
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => provider.fetchReviews(),
              child: reviews.isEmpty
                  ? Center(
                      child: Text(
                        'No hay propuestas para revisión.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20.0),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final data = review.proposalData;
                        final aiAnalysis = data['ai_analysis'] as Map<String, dynamic>? ?? {};
                        final ollamaAnalysis = aiAnalysis['ollama_analysis'] as Map<String, dynamic>? ?? {};
                        final teamInfo = data['team_info'] as Map<String, dynamic>? ?? {};

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
                        final dateStr = DateFormat('dd MMM yyyy').format(review.createdAt);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfReviewDetailPage(review: review),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusBgColor(review.status, colorScheme),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _getTranslatedStatus(review.status),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusTextColor(review.status, colorScheme),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        dateStr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    projectName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Equipo: $teamName',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (membersList.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Integrantes: ${membersList.join(', ')}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (review.status == 'SUMMONED' && review.appointmentDate != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.event, size: 14, color: Colors.orange),
                                          const SizedBox(width: 6),
                                          Text(
                                            DateFormat('dd/MM/yyyy hh:mm a').format(review.appointmentDate!.toLocal()),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
