import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/corvus_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/notifications/presentation/provider/notifications_provider.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/shared/widgets/project_card.dart';
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<InspirationProvider>();
      if (provider.projects.isEmpty && !provider.isLoading) {
        provider.loadProjects();
      }
    });
  }

  void _scrollListener() {
    // El usuario pidió que la tarjeta no desaparezca al deslizar.
    // Solo se ocultará al picarle al botón de cerrar.
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<InspirationProvider>().loadMore();
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
    final isFetchingMore = context.select<InspirationProvider, bool>((p) => p.isFetchingMore);
    final showWelcome = context.select<InspirationProvider, bool>((p) => p.showWelcome);
    final projectCount = context.select<InspirationProvider, int>((p) => p.projects.length);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    // AppBar sliver que se oculta al hacer scroll hacia arriba
                    const _SliverTopBar(),

                    // Contenido superior (welcome + header fijo de sección)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            if (showWelcome)
                              _WelcomeCard(onDismiss: () => context.read<InspirationProvider>().dismissWelcome()),
                          ],
                        ),
                      ),
                    ),

                    // Header de sección pinned: queda fijo al scroll
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SectionHeaderDelegate(),
                    ),

                    // Lista de proyectos
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

                    // Indicador de carga (loadMore)
                    if (isFetchingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: CircularProgressIndicator(),
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

/// AppBar como sliver que se oculta al hacer scroll hacia arriba
/// y vuelve a aparecer al hacer scroll hacia abajo.
class _SliverTopBar extends StatelessWidget {
  const _SliverTopBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      backgroundColor: colorScheme.surface,
      scrolledUnderElevation: 0,
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Image.asset(
        'assets/icons/logo2.png',
        height: 32,
        width: 32,
      ),
      actions: const [
        _NotificationsAction(),
        _ProfileAction(),
        SizedBox(width: 8),
      ],
    );
  }
}

class _NotificationsAction extends StatelessWidget {
  const _NotificationsAction();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, notificationsProvider, child) {
        final unreadCount = notificationsProvider.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              onPressed: () {
                context.push('/notifications');
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction();

  @override
  Widget build(BuildContext context) {
    final photoUrl = context.select<AuthProvider, String?>((a) => a.currentUser?.photoUrl);
    final role = context.select<AuthProvider, String?>((a) => a.role);

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Material(
          type: MaterialType.circle,
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToProfile(context, role),
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              backgroundImage: NetworkImage(photoUrl),
              radius: 18,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () => _navigateToProfile(context, role),
        child: const CircleAvatar(
          radius: 18,
          child: Icon(Icons.person),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, String? role) {
    if (role == 'PROFESOR') {
      if (GoRouterState.of(context).matchedLocation != '/prof-profile') {
        context.push('/prof-profile');
      }
    } else {
      if (GoRouterState.of(context).matchedLocation != '/profile') {
        context.push('/profile');
      }
    }
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
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.7),
              colorScheme.secondaryContainer.withValues(alpha: 0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin)
          .copyWith(top: 12, bottom: 12),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.unexploredProjects,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.unexploredProjectsDesc,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class _SkeletonLoaderList extends StatelessWidget {
  const _SkeletonLoaderList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => _buildSkeletonCard(context)),
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CorvusSkeleton(width: 180, height: 18, borderRadius: BorderRadius.all(Radius.circular(9))),
            const SizedBox(height: 8),
            const CorvusSkeleton(width: double.infinity, height: 13, borderRadius: BorderRadius.all(Radius.circular(4))),
            const SizedBox(height: 6),
            const CorvusSkeleton(width: double.infinity, height: 13, borderRadius: BorderRadius.all(Radius.circular(4))),
            const SizedBox(height: 6),
            const CorvusSkeleton(width: 200, height: 13, borderRadius: BorderRadius.all(Radius.circular(4))),
            const SizedBox(height: 16),
            Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.12)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(3, (_) => const CorvusSkeleton(
                width: 100,
                height: 28,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              )),
            ),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CorvusSkeleton(width: 60, height: 14, borderRadius: BorderRadius.all(Radius.circular(7))),
                CorvusSkeleton(width: 44, height: 44, borderRadius: BorderRadius.all(Radius.circular(12))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}