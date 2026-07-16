import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/my_project/presentation/widgets/innovation_card.dart';
import 'package:mobile/features/my_project/presentation/pages/project_defense_chat_page.dart';
import 'package:mobile/features/my_project/presentation/widgets/upload_zone_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/uploaded_file_item_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/fast_rag_analysis_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/detailed_analysis_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/animated_loading_text_widget.dart';
import 'package:mobile/features/my_project/presentation/widgets/invalid_document_widget.dart';

import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/core/theme/app_dimens.dart';

class MyProjectPage extends StatelessWidget {
  const MyProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MyProjectPageContent();
  }
}

class _MyProjectPageContent extends StatefulWidget {
  const _MyProjectPageContent();

  @override
  State<_MyProjectPageContent> createState() => _MyProjectPageContentState();
}

class _MyProjectPageContentState extends State<_MyProjectPageContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MyProjectProvider>();
      final token = context.read<AuthProvider>().currentUser?.token;
      
      provider.setScreenVisible(true);
      if (provider.state == ProjectState.initial) {
        final userId = context.read<AuthProvider>().currentUser?.id;
        final teamId = context.read<TeamsProvider>().myTeam?.id;
        final universityId = context.read<AuthProvider>().currentUser?.universityId;
        final careerId = context.read<AuthProvider>().currentUser?.careerId;
        provider.setContext(universityId: universityId, careerId: careerId);
        if (userId != null && teamId != null) {
          provider.init(userId, teamId);
        }
      }

      if (token != null) {
        context.read<ProjectProvider>().loadMyProjects(token);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
        context.read<MyProjectProvider>().setScreenVisible(false);
    } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final provider = context.read<MyProjectProvider>();
    if (state == AppLifecycleState.resumed) {
      provider.setScreenVisible(true);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      provider.setScreenVisible(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String>(
      (a) => a.currentUser?.id ?? 'default_user',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CorvusTopBar(),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            final provider = context.read<MyProjectProvider>();
            final teamId = context.read<TeamsProvider>().myTeam?.id;
            if (teamId != null) {
              await provider.init(userId, teamId, forceRefresh: true);
            }
          },
          child: Consumer<ProjectProvider>(
            builder: (context, projectProvider, child) {
              if (projectProvider.isLoading && projectProvider.myProjects.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (projectProvider.myProjects.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.class_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(
                          'Aún no perteneces a ningún proyecto',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Para poder formar un equipo y subir tu propuesta, primero debes unirte a la clase de tu profesor usando su Código de Acceso.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        CorvusButton(
                          text: 'Unirse a un Proyecto',
                          onPressed: () => context.push('/join-project'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _ProjectPageHeader(userId: userId),

                    const SizedBox(height: 24),

                    RepaintBoundary(
                      child: _ProjectPageBody(userId: userId),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// -# 
class _ProjectPageHeader extends StatelessWidget {
  final String userId;
  const _ProjectPageHeader({required this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final state = context.select<MyProjectProvider, ProjectState>((p) => p.state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                state == ProjectState.detailedAnalysis
                    ? l10n.detailedAnalysisTitle
                    : l10n.preValidationTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Tooltip(
              message: state == ProjectState.detailedAnalysis ? l10n.detailedAnalysisDesc : l10n.preValidationDesc,
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 4),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(color: colorScheme.onInverseSurface, fontSize: 14),
              child: IconButton(
                icon: Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant, size: 20),
                onPressed: () {}, // Tooltip handles tap
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          state == ProjectState.detailedAnalysis
              ? l10n.detailedAnalysisDesc
              : l10n.preValidationDesc,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

// Skeleton shown while MyProjectProvider initializes in background
class _ProjectLoadingSkeleton extends StatefulWidget {
  const _ProjectLoadingSkeleton();

  @override
  State<_ProjectLoadingSkeleton> createState() => _ProjectLoadingSkeletonState();
}

class _ProjectLoadingSkeletonState extends State<_ProjectLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar({double width = double.infinity, double height = 14, double radius = 6}) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, _) => Opacity(
        opacity: _opacity.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Innovation card skeleton
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _bar(width: 140, height: 18),
                  const SizedBox(height: 20),
                  _bar(width: 120, height: 120, radius: 60),
                  const SizedBox(height: 20),
                  _bar(width: 80, height: 14),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Metrics skeleton
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: 160, height: 18),
                  const SizedBox(height: 24),
                  _bar(height: 8),
                  const SizedBox(height: 20),
                  _bar(height: 8),
                  const SizedBox(height: 20),
                  _bar(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Recommendations skeleton
            _bar(width: 180, height: 18),
            const SizedBox(height: 16),
            for (int i = 0; i < 3; i++) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(width: 180, height: 14),
                    const SizedBox(height: 10),
                    _bar(height: 10),
                    const SizedBox(height: 6),
                    _bar(width: 220, height: 10),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// -# 
class _ProjectPageBody extends StatelessWidget {
  final String userId;
  const _ProjectPageBody({required this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<MyProjectProvider>();
    final teamsProvider = context.watch<TeamsProvider>();
    final finalReviewStatus = teamsProvider.finalReviewStatus;
    final isUnderReview = finalReviewStatus != null && finalReviewStatus['status'] != 'REJECTED';
    final auth = context.read<AuthProvider>();
    final isLeader = teamsProvider.myTeam != null && teamsProvider.myTeam!.members.isNotEmpty && 
                    (teamsProvider.myTeam!.members[0].id == userId || teamsProvider.myTeam!.members[0].email == auth.currentUser?.email);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Column(
        key: ValueKey('project_page_body_base'),
        children: [
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

          if (provider.documentTypeError != null)
            InvalidDocumentWidget(
              provider: provider,
              userId: userId,
              specificError: provider.documentTypeError!,
            ),

          // Show skeleton while loading initial state (provider is initializing in background)
          if (provider.state == ProjectState.initial)
            const _ProjectLoadingSkeleton(),

        if (provider.state != ProjectState.initial)
          _ProjectRequirementsWidget(provider: provider),

        // Show upload zone only after init resolved AND there's an error (no analysis found)
        if (provider.state == ProjectState.error && provider.documentTypeError == null)
          if (isLeader)
            UploadZoneWidget(provider: provider)
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Esperando a que el líder del equipo suba la propuesta.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

        if (provider.state == ProjectState.detailedAnalysis && provider.detailedAnalysis != null)
          Builder(
            builder: (context) {
              final ollamaAnalysis = provider.detailedAnalysis!['ollama_analysis'] as Map<String, dynamic>? ?? {};
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
              final projectName = extractedProjectName ?? provider.fileName?.replaceAll('.pdf', '') ?? 'Propuesta sin título';

              final myTeam = teamsProvider.myTeam;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  if (provider.detailedAnalysis?['uploaded_by'] != null || provider.quickAnalysis?['uploaded_by'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Subido por: ${provider.detailedAnalysis?['uploaded_by'] ?? provider.quickAnalysis?['uploaded_by']}',
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (myTeam != null)
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
                                  'Equipo: ${myTeam.name}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('Integrantes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          ...myTeam.members.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(m.name, style: const TextStyle(fontSize: 14))),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

        if (provider.state != ProjectState.initial &&
            provider.state != ProjectState.error &&
            provider.fileName != null)
          UploadedFileItemWidget(provider: provider),

        if (provider.state == ProjectState.uploading)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const RepaintBoundary(child: _PreValidationLoadingTextWidget()),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => provider.cancelAnalysis(userId, context.read<TeamsProvider>().myTeam?.id ?? ''),
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

        if (provider.state == ProjectState.preValidated && provider.quickAnalysis != null)
          FastRagAnalysisWidget(data: provider.quickAnalysis!),

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
                  onPressed: () => provider.cancelAnalysis(userId, context.read<TeamsProvider>().myTeam?.id ?? ''),
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

        if (provider.state == ProjectState.detailedAnalysis && provider.detailedAnalysis != null)
          DetailedAnalysisWidget(
            data: Map<String, dynamic>.from(provider.detailedAnalysis!['ollama_analysis'] as Map? ?? {}),
          ),

        const SizedBox(height: 12),

        if (provider.state == ProjectState.preValidated) ...[

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                final teamId = context.read<TeamsProvider>().myTeam?.id ?? '';
                provider.submitForReview(userId, teamId, l10n);
              },
              icon: const Icon(Icons.analytics, size: 18),
              label: Text(l10n.sendForReview, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],

        if (provider.state == ProjectState.detailedAnalysis) ...[
          if (isUnderReview)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.rate_review, color: colorScheme.onSecondaryContainer, size: 32),
                  const SizedBox(height: 8),
                  Text('Propuesta en Revisión Final', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSecondaryContainer)),
                  const SizedBox(height: 8),
                  Text('Tu equipo ya ha enviado esta propuesta a revisión final. Estado actual: ${finalReviewStatus['status']}', 
                    style: TextStyle(color: colorScheme.onSecondaryContainer),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            if (!provider.hasPassedDefense)
              SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        final teamsProvider = context.read<TeamsProvider>();
                        final profileProvider = context.read<ProfileProvider>();
                        final teamId = teamsProvider.myTeam?.id ?? '';
                        final studentName = profileProvider.profile?.alumno ?? 'Estudiante';
                        
                        return ProjectDefenseChatPage(
                          teamId: teamId,
                          studentName: studentName,
                          teamMembers: teamsProvider.myTeam?.members.map((m) => m.name).toList(),
                          proposalSummary: provider.detailedAnalysis?['verdict'] ?? 'Propuesta de innovación',
                          analysisResult: provider.detailedAnalysis ?? {},
                        );
                      },
                    ),
                  );
                  if (result != null && result is List<Map<String, String>>) {
                    provider.setDefensePassed(result);
                  }
                },
                icon: const Icon(Icons.security, size: 18),
                label: const Text('Defender Propuesta ante IA', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.tertiary,
                  foregroundColor: colorScheme.onTertiary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else if (isLeader)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final teamsProvider = context.read<TeamsProvider>();
                  if (teamsProvider.myTeam == null) {
                    await teamsProvider.fetchMyTeam();
                  }
                  
                  final myTeam = teamsProvider.myTeam;
                  if (myTeam == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No tienes un equipo asignado. Ve a la pestaña Equipos primero.')));
                    }
                    return;
                  }
                  
                  final auth = context.read<AuthProvider>();
                  final isLeader = myTeam.members.isNotEmpty && (myTeam.members[0].id == userId || myTeam.members[0].email == auth.currentUser?.email);
                  if (!isLeader) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Solo el líder del equipo puede enviar la propuesta a revisión final.'),
                          backgroundColor: Colors.orange,
                        )
                      );
                    }
                    return;
                  }

                  final success = await provider.sendFinalReview(
                    teamId: myTeam.id,
                    teamName: myTeam.name,
                    memberNames: myTeam.members.map((m) => m.name).toList(),
                    universityName: myTeam.project?['university_name'] ?? 'General',
                    careerName: myTeam.project?['career_name'] ?? 'General',
                    professorName: myTeam.project?['professor_name'] ?? 'Profesor',
                  );
                  if (success && context.mounted) {
                     await teamsProvider.fetchMyTeam();
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(
                           content: Text('✅ Propuesta enviada a revisión final exitosamente.'),
                           backgroundColor: Colors.green,
                         ),
                       );
                     }
                  }
                },
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Enviar a Revisión Final', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          const SizedBox(height: 12),
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
        ],
      ],
    ),
    );
  }
}

class _PreValidationLoadingTextWidget extends StatelessWidget {
  const _PreValidationLoadingTextWidget();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final message = context.select<MyProjectProvider, String>((p) => p.serverPhaseMessage);
    
    String icon = '📄';
    final msgLower = message.toLowerCase();
    if (msgLower.contains('modelo') || msgLower.contains('clasificador')) {
      icon = '🤖';
    } else if (msgLower.contains('blacklist') || msgLower.contains('comunes')) icon = '🚫';
    else if (msgLower.contains('secciones')) icon = '📚';
    else if (msgLower.contains('coherencia')) icon = '⚖️';
    else if (msgLower.contains('colision') || msgLower.contains('qdrant')) icon = '🔍';
    else if (msgLower.contains('pre-validación')) icon = '⏳';

    final displayText = message.isEmpty ? 'Iniciando pre-validación...' : message;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey<String>(displayText),
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 12),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProjectRequirementsWidget extends StatelessWidget {
  final MyProjectProvider provider;

  const _ProjectRequirementsWidget({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Requisitos del Profesor',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.projectSections.isNotEmpty) ...[
            Text(
              'Estructura esperada:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: provider.projectSections.map((sectionMap) {
                final name = sectionMap['nombre'] as String? ?? '';
                final isObligatory = sectionMap['obligatoria'] as bool? ?? false;
                final descripcion = sectionMap['descripcion'] as String?;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isObligatory ? colorScheme.primaryContainer.withValues(alpha: 0.5) : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isObligatory ? 'Obligatoria' : 'Opcional',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isObligatory ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (descripcion != null && descripcion.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          descripcion,
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (provider.exclusionRules.isNotEmpty) ...[
            Text(
              'Temas bloqueados:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.exclusionRules.map((rule) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block, size: 12, color: colorScheme.error),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          rule,
                          style: TextStyle(fontSize: 12, color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
