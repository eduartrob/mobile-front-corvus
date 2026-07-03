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

class _MyProjectPageContentState extends State<_MyProjectPageContent> {
  @override
  void initState() {
    super.initState();
    // Safety net: if the global provider hasn't been init()'d yet
    // (e.g. fresh login where the listener fired before userId was set),
    // trigger it now. init() has an _initialized guard so it's safe to call.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MyProjectProvider>();
      if (provider.state == ProjectState.initial) {
        final userId = context.read<AuthProvider>().currentUser?.id;
        if (userId != null) {
          provider.init(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String>(
      (a) => a.currentUser?.id ?? 'default_user',
    );

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProjectPageHeader(userId: userId),

            const SizedBox(height: 24),

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
        Text(
          state == ProjectState.detailedAnalysis
              ? l10n.detailedAnalysisTitle
              : l10n.preValidationTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.85),
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
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Innovation card skeleton
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
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

    return Column(
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

        // Show upload zone only after init resolved AND there's an error (no analysis found)
        if (provider.state == ProjectState.error && provider.documentTypeError == null)
          UploadZoneWidget(provider: provider),

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

        if (provider.state == ProjectState.detailedAnalysis && provider.detailedAnalysis != null)
          DetailedAnalysisWidget(data: provider.detailedAnalysis!['ollama_analysis'] ?? {}),

        const SizedBox(height: 12),

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

class _PreValidationLoadingTextWidget extends StatefulWidget {
  const _PreValidationLoadingTextWidget();

  @override
  State<_PreValidationLoadingTextWidget> createState() => _PreValidationLoadingTextWidgetState();
}

class _PreValidationLoadingTextWidgetState extends State<_PreValidationLoadingTextWidget> {
  int _currentIndex = 0;
  
  final List<Map<String, String>> _phases = [
    {'icon': '📄', 'text': 'Extrayendo texto del documento...'},
    {'icon': '🤖', 'text': 'Limpiando y estructurando propuesta...'},
    {'icon': '📚', 'text': 'Verificando secciones académicas obligatorias...'},
    {'icon': '⚖️', 'text': 'Evaluando coherencia interna...'},
    {'icon': '🔍', 'text': 'Buscando colisiones con proyectos anteriores...'},
  ];

  @override
  void initState() {
    super.initState();
    _cycleMessages();
  }

  void _cycleMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          if (_currentIndex < _phases.length - 1) {
            _currentIndex++;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final phaseData = _phases[_currentIndex];

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
        key: ValueKey<int>(_currentIndex),
        children: [
          Text(
            phaseData['icon']!,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 12),
          Text(
            phaseData['text']!,
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
