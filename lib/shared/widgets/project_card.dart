import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:mobile/features/inspiration/presentation/pages/blue_ocean_detail_page.dart';

/// Tarjeta reutilizable para mostrar proyectos de inspiración/inexplorados.
/// Usada en Inspiration y SavedProjects.
class ProjectCard extends StatelessWidget {
  final ProjectEntity project;

  static const List<List<Color>> pastelGradients = [
    [Color(0xFFB5F2CA), Color(0xFFFBF1B7)],
    [Color(0xFFB5E0F2), Color(0xFFC7B5F2)],
    [Color(0xFFF2B5C7), Color(0xFFF2D0B5)],
    [Color(0xFFB5F2E3), Color(0xFFB5CFF2)],
    [Color(0xFFF2CCB5), Color(0xFFFBF4B7)],
    [Color(0xFFD4B5F2), Color(0xFFF2B5DE)],
    [Color(0xFFFBF4B7), Color(0xFFB5F2C1)],
    [Color(0xFFF2B5B5), Color(0xFFF2CEB5)],
    [Color(0xFFB5D4F2), Color(0xFFD0B5F2)],
    [Color(0xFFCEF2B5), Color(0xFFB5E9F2)],
  ];

  const ProjectCard({super.key, required this.project});

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
      final updated = await provider.trackNicheView(project.id, avatarUrl);
      if (updated != null) {
        projectToNav = updated;
      }
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
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final analysis = project.analysisData ?? {};

    final String displayTitle = (analysis['titulo_propuesta'] != null && analysis['titulo_propuesta'].toString().isNotEmpty)
        ? analysis['titulo_propuesta'].toString()
        : project.title;

    final String mainFinding = (analysis.isNotEmpty)
        ? (isEn
            ? (analysis['hallazgo_principal_en'] ?? analysis['hallazgo_principal'] ?? '')
            : (analysis['hallazgo_principal_es'] ?? analysis['hallazgo_principal'] ?? ''))
        : '';

    final String descriptionText = mainFinding.isNotEmpty
        ? mainFinding
        : project.description;

    final List<dynamic> suggestions = isEn
        ? ((analysis['sugerencias_en'] as List<dynamic>?) ?? (analysis['sugerencias'] as List<dynamic>?) ?? [])
        : ((analysis['sugerencias_es'] as List<dynamic>?) ?? (analysis['sugerencias'] as List<dynamic>?) ?? []);

    // Seleccionamos un gradiente basado en el ID del proyecto para que sea consistente
    final int colorIndex = project.id.hashCode.abs() % pastelGradients.length;
    final gradientColors = pastelGradients[colorIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CorvusAnimatedCard(
            onTap: () => _handleTap(context),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            descriptionText,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF3B3B3B),
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (suggestions.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: suggestions.take(3).map((s) {
                                final title = s['titulo']?.toString() ?? '';
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      color: Color(0xFF3B3B3B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        if (isTrending)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: AnimatedFireIcon(),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.groups_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                          ),
                        Expanded(
                          child: Text(
                            '+ ${project.viewCount} Estudiantes han presionado aqui',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (project.analysisStatus == 'pending')
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onSurface),
                          )
                        else
                          Icon(Icons.arrow_forward, color: colorScheme.onSurface, size: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (isTrending)
            Positioned(
              top: -8,
              right: 14,
              child: ProjectTrendingBadge(viewCount: project.viewCount),
            ),
        ],
      ),
    );
  }
}

/// Mini-card de sugerencia metodológica usada dentro de [ProjectCard].
class ProjectSuggestionMiniCard extends StatelessWidget {
  final dynamic suggestion;

  const ProjectSuggestionMiniCard({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = suggestion['titulo']?.toString() ?? '';
    final isRecommended = suggestion['tipo']?.toString() == 'Recomendado';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isRecommended ? colorScheme.primary : colorScheme.onSurface,
                    height: 1.25,
                  ),
                ),
              ),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Recomendado',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón cuadrado de "explorar" usado dentro de [ProjectCard].
class ProjectExploreButton extends StatelessWidget {
  final bool isPending;

  const ProjectExploreButton({super.key, required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: isPending
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
              )
            : const Icon(Icons.arrow_forward, color: Colors.black87, size: 20),
      ),
    );
  }
}

/// Badge "Trending" usado dentro de [ProjectCard].
class ProjectTrendingBadge extends StatelessWidget {
  final int viewCount;

  const ProjectTrendingBadge({super.key, required this.viewCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔥', style: TextStyle(fontSize: 13, color: colorScheme.primary)),
            const SizedBox(width: 4),
            Text(
              'Trending · $viewCount vistas',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
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

/// Wrapper animado reutilizable para tarjetas interactivas.
class CorvusAnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const CorvusAnimatedCard({super.key, required this.child, required this.onTap});

  @override
  State<CorvusAnimatedCard> createState() => _CorvusAnimatedCardState();
}

class _CorvusAnimatedCardState extends State<CorvusAnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 10, 
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Theme.of(context).colorScheme.surfaceContainerHighest 
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
          onHighlightChanged: (isHighlighted) {
            if (isHighlighted) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          },
          child: widget.child,
        ),
      ),
      ),
    );
  }
}

/// Icono animado de fuego que palpita suavemente
class AnimatedFireIcon extends StatefulWidget {
  const AnimatedFireIcon({super.key});

  @override
  State<AnimatedFireIcon> createState() => _AnimatedFireIconState();
}

class _AnimatedFireIconState extends State<AnimatedFireIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: const Text('🔥', style: TextStyle(fontSize: 16)),
    );
  }
}