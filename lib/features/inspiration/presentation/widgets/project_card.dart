import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:mobile/features/inspiration/presentation/widgets/glass_container.dart';
import 'package:mobile/features/inspiration/presentation/pages/blue_ocean_detail_page.dart';
import 'package:mobile/l10n/app_localizations.dart';

class ProjectCard extends StatelessWidget {
  final ProjectEntity project;

  const ProjectCard({super.key, required this.project});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'auto_awesome': return Icons.auto_awesome;
      case 'local_shipping': return Icons.local_shipping;
      case 'biotech': return Icons.biotech;
      default: return Icons.star;
    }
  }

  Color _viewCountColor(BuildContext context) {
    if (project.isTrending) return Colors.orange.shade600;
    if (project.viewCount < 10) return Colors.teal.shade600;
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Future<void> _handleTap(BuildContext context) async {
    if (project.analysisStatus == 'pending') {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La IA está generando el análisis detallado. Vuelve en un momento.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final avatarUrl = authProvider.currentUser?.photoUrl;
    final provider = context.read<InspirationProvider>();
    
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final localNavigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    ProjectEntity? projectToNav = project;

    if (project.analysisData == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (c) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
      );
      
      projectToNav = await provider.trackNicheView(project.id, avatarUrl);
      
      rootNavigator.pop();
    } else {
      provider.trackNicheView(project.id, avatarUrl);
    }

    if (projectToNav != null) {
      localNavigator.push(
        MaterialPageRoute(
          builder: (context) => BlueOceanDetailPage(project: projectToNav!),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Error al cargar los detalles. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final bool isTrending = project.isTrending;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _AnimatedCardWrapper(
              onTap: () => _handleTap(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getIconData(project.categoryIcon), size: 14, color: colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            project.category == 'INNOVACIÓN ACADÉMICA' ? l10n.blueOceanGenericCategory : project.category,
                            style: TextStyle(fontSize: 12, color: colorScheme.secondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isTrending ? Colors.orange.withOpacity(0.15) : colorScheme.tertiaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isTrending ? Icons.local_fire_department : Icons.insights, size: 14, color: isTrending ? Colors.orange.shade600 : colorScheme.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            isTrending ? 'Trending' : (project.status == 'Océano Azul Real' ? l10n.blueOceanGenericTag : project.status),
                            style: TextStyle(fontSize: 12, color: isTrending ? Colors.orange.shade800 : colorScheme.tertiary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (!isTrending && project.viewCount < 10)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🌊', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              'Océano Virgen',
                              style: TextStyle(fontSize: 11, color: Colors.teal.shade700, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  project.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.2),
                ),
                const SizedBox(height: 6),

                Text(
                  project.description.startsWith('Este proyecto ha sido clasificado') 
                      ? l10n.blueOceanGenericDesc 
                      : project.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant.withOpacity(0.8), height: 1.5),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _ViewersAndCountRow(
                      viewers: project.recentViewers, 
                      totalViews: project.viewCount,
                      isTrending: isTrending,
                    ),

                    const Spacer(),

                    // Botón Explorar puramente visual
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (project.analysisStatus == 'pending') ...[
                            Text(
                              'Generando...',
                              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 12, height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onSurfaceVariant),
                            )
                          ] else ...[
                            Text(
                              l10n.explore,
                              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward, color: colorScheme.primary, size: 16),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

          if (isTrending)
            Positioned(
              top: -10,
              right: 12,
              child: _TrendingBadge(viewCount: project.viewCount),
            ),
        ],
      ),
      const Divider(height: 1, thickness: 0.5),
    ],
  );
  }
}

// -# 
class _TrendingBadge extends StatelessWidget {
  final int viewCount;
  const _TrendingBadge({required this.viewCount});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade700, Colors.deepOrange.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              'Trending · $viewCount vistas',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -# 
class _ViewersAndCountRow extends StatelessWidget {
  final List<String> viewers;
  final int totalViews;
  final bool isTrending;
  
  const _ViewersAndCountRow({
    required this.viewers,
    required this.totalViews,
    required this.isTrending,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (totalViews == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_off_outlined, size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(width: 6),
          Text(
            '0',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      );
    }

    final displayViewers = viewers.take(3).toList();
    final remainingViews = totalViews - displayViewers.length;
    final showRemaining = remainingViews > 0;
    
    const avatarSize = 24.0;
    const overlap = 16.0;
    
    final totalElements = displayViewers.length + (showRemaining ? 1 : 0);
    final rowWidth = avatarSize + (totalElements > 0 ? (totalElements - 1) * overlap : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: rowWidth,
          height: avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < displayViewers.length; i++)
                Positioned(
                  left: i * overlap,
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(displayViewers[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
              if (showRemaining)
                Positioned(
                  left: displayViewers.length * overlap,
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isTrending ? Colors.orange.shade50 : colorScheme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    child: Text(
                      '+$remainingViews',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isTrending ? Colors.orange.shade800 : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        if (isTrending) ...[
          const SizedBox(width: 8),
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 2),
          Text(
            'Trending',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
        ]
      ],
    );
  }
}

class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedCardWrapper({required this.child, required this.onTap});

  @override
  State<_AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<_AnimatedCardWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
