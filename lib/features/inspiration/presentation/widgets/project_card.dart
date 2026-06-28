import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/providers/auth_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final bool isTrending = project.isTrending;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Tarjeta principal ──
          GlassContainer(
            blur: 0,
            opacity: 0.5,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            // Borde sutil naranja si es trending
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Chips de categoría y estado ──
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Chip categoría
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.secondaryContainer.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getIconData(project.categoryIcon), size: 14, color: colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            project.category,
                            style: TextStyle(fontSize: 12, color: colorScheme.secondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    // Chip estado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
                      ),
                      child: Text(
                        project.status,
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                    ),
                    // Badge de vistas (poco explorado = distintivo especial)
                    if (!isTrending && project.viewCount < 10)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.teal.withOpacity(0.4)),
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

                const SizedBox(height: 16),

                // ── Título ──
                Text(
                  project.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2),
                ),
                const SizedBox(height: 8),

                // ── Descripción ──
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 12),

                // ── Fila inferior: vistos recientemente + contador + explorar ──
                Row(
                  children: [
                    // Avatares de vistos recientemente
                    if (project.recentViewers.isNotEmpty)
                      _RecentViewersRow(viewers: project.recentViewers),
                    if (project.recentViewers.isEmpty)
                      Text(
                        '¡Sé el primero en explorar!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal.shade600,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    const Spacer(),

                    // Contador de vistas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isTrending
                            ? Colors.orange.withOpacity(0.1)
                            : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 13,
                            color: _viewCountColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${project.viewCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _viewCountColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Botón explorar / Generando
                    InkWell(
                      onTap: () {
                        if (project.analysisStatus == 'pending') {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('La IA está generando el análisis detallado. Vuelve en un momento.'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        // Status completed -> Registrar vista y Navegar
                        final authProvider = context.read<AuthProvider>();
                        final avatarUrl = authProvider.currentUser?.photoUrl;
                        
                        context.read<InspirationProvider>().trackNicheView(project.id, avatarUrl);
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlueOceanDetailPage(project: project),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (project.analysisStatus == 'pending') ...[
                              Text(
                                'Generando...',
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 12, height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onSurfaceVariant),
                              )
                            ] else ...[
                              Text(
                                l10n.explore,
                                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward, color: colorScheme.primary, size: 16),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Badge 🔥 TRENDING (esquina superior derecha, fuera de la tarjeta) ──
          if (isTrending)
            Positioned(
              top: -10,
              right: 12,
              child: _TrendingBadge(viewCount: project.viewCount),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRENDING BADGE — aparece cuando viewCount >= 50
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// RECENT VIEWERS ROW — avatares apilados de los últimos que revisaron el nicho
// ─────────────────────────────────────────────────────────────────────────────
class _RecentViewersRow extends StatelessWidget {
  final List<String> viewers;
  const _RecentViewersRow({required this.viewers});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayViewers = viewers.take(3).toList();
    const avatarSize = 22.0;
    const overlap = 14.0;
    final rowWidth = avatarSize + (displayViewers.length - 1) * overlap;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: rowWidth + 4,
          height: avatarSize,
          child: Stack(
            children: [
              for (int i = 0; i < displayViewers.length; i++)
                Positioned(
                  left: i * overlap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundImage: NetworkImage(displayViewers[i]),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          viewers.length == 1 ? 'Lo vio recientemente' : 'Lo vieron recientemente',
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
