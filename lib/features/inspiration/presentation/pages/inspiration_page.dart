import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/features/inspiration/presentation/widgets/glass_container.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/features/inspiration/presentation/widgets/project_card.dart';
import 'package:mobile/features/inspiration/presentation/widgets/floating_ai_input.dart';

class InspirationPage extends StatefulWidget {
  const InspirationPage({super.key});

  @override
  State<InspirationPage> createState() => _InspirationPageState();
}

class _InspirationPageState extends State<InspirationPage> {
  late final ScrollController _scrollController;
  bool _isFloatingInputVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isFloatingInputVisible) {
      setState(() => _isFloatingInputVisible = false);
    } else if (direction == ScrollDirection.forward && !_isFloatingInputVisible) {
      setState(() => _isFloatingInputVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<InspirationProvider, bool>((p) => p.isLoading);
    final showWelcome = context.select<InspirationProvider, bool>((p) => p.showWelcome);
    final projectCount = context.select<InspirationProvider, int>((p) => p.projects.length);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CorvusTopBar(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),

          RepaintBoundary(
            child: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                key: context.read<InspirationProvider>().refreshIndicatorKey,
                onRefresh: () => context.read<InspirationProvider>().loadProjects(forceRefresh: true),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            if (showWelcome)
                              _WelcomeCard(onDismiss: () => context.read<InspirationProvider>().dismissWelcome()),
                            const _SectionHeader(),
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
                      sliver: (isLoading && projectCount == 0)
                          ? const SliverToBoxAdapter(
                              child: _SkeletonLoaderList(),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final project = context.read<InspirationProvider>().projects[index];
                                  return RepaintBoundary(
                                    child: ProjectCard(project: project),
                                  );
                                },
                                childCount: projectCount,
                              ),
                            ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 160)),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: RepaintBoundary(
              child: FloatingAiInput(
                isVisible: _isFloatingInputVisible,
                onExpand: () {
                  if (!_isFloatingInputVisible) {
                    setState(() => _isFloatingInputVisible = true);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -# 
class _WelcomeCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const _WelcomeCard({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: GlassContainer(
        blur: 0,
        opacity: 0.5,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: colorScheme.secondary, size: 24),
                const SizedBox(width: 8),
                Text(
                  l10n.welcomeToCorvus,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.welcomeCorvusDesc,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDismiss,
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -# 
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.unexploredProjects,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.unexploredProjectsDesc,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SkeletonLoaderList extends StatefulWidget {
  const _SkeletonLoaderList();
  
  @override
  State<_SkeletonLoaderList> createState() => _SkeletonLoaderListState();
}

class _SkeletonLoaderListState extends State<_SkeletonLoaderList> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800)
    )..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Column(
            children: List.generate(3, (index) => _buildSkeletonCard(context)),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassContainer(
        blur: 0,
        opacity: 0.3,
        border: Border.all(color: Colors.transparent),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 100, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 8),
                Container(width: 80, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12))),
              ],
            ),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(width: 200, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 60, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12))),
                Container(width: 100, height: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
