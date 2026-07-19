import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/services/security_service.dart';
import 'package:lottie/lottie.dart';

// ─── Data ───────────────────────────────────────────────────────────────────

class _OnboardingSlideData {
  final String title;
  final String description;
  final String lottiePath;

  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.lottiePath,
  });
}

// ─── Page ───────────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final SecurityService _securityService = SecurityService();
  int _currentPage = 0;
  bool _isAnimatingTransition = false;

  late AnimationController _revealController;
  late Animation<double> _revealAnimation;
  
  Offset _buttonPosition = Offset.zero;
  final GlobalKey _buttonKey = GlobalKey();

  static const List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      title: 'IA para Estudiantes',
      description: 'Analiza el impacto y factibilidad de tus proyectos académicos con nuestra inteligencia artificial.',
      lottiePath: 'assets/animations/Ai-powered marketing tools abstract.json',
    ),
    _OnboardingSlideData(
      title: 'Organización para Docentes',
      description: 'Evalúa propuestas, gestiona equipos y colabora con alumnos en una misma plataforma.',
      lottiePath: 'assets/animations/Profesor.json',
    ),
    _OnboardingSlideData(
      title: 'Evaluación y Originalidad',
      description: 'Realiza pruebas, evalúa rúbricas y asegura la integridad de los proyectos en Corvus.',
      lottiePath: 'assets/animations/quiz.json',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeInOutCubic,
    );
    
    // We start the first slide transition instantly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateButtonPosition();
      _revealController.value = 1.0;
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _securityService.preventScreenshots(false);
    super.dispose();
  }

  void _updateButtonPosition() {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      // Button center
      _buttonPosition = Offset(
        position.dx + size.width / 2,
        position.dy + size.height / 2,
      );
    }
  }

  Color _getBackgroundColor(int index, ColorScheme colors) {
    switch (index) {
      case 0:
        return colors.primaryContainer;
      case 1:
        return colors.tertiaryContainer;
      case 2:
        return colors.secondaryContainer;
      default:
        return colors.primaryContainer;
    }
  }

  Color _getForegroundColor(int index, ColorScheme colors) {
    switch (index) {
      case 0:
        return colors.onPrimaryContainer;
      case 1:
        return colors.onTertiaryContainer;
      case 2:
        return colors.onSecondaryContainer;
      default:
        return colors.onPrimaryContainer;
    }
  }

  Future<void> _skipOrComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    context.go('/login');
  }

  void _next() {
    if (_isAnimatingTransition) return;
    
    if (_currentPage < _slides.length - 1) {
      _updateButtonPosition();
      setState(() {
        _isAnimatingTransition = true;
      });
      
      _revealController.forward(from: 0.0).then((_) {
        setState(() {
          _currentPage++;
          _isAnimatingTransition = false;
        });
      });
    } else {
      _skipOrComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    final currentBgColor = _getBackgroundColor(_currentPage, colors);
    final nextBgColor = _getBackgroundColor(
        _currentPage < _slides.length - 1 ? _currentPage + 1 : _currentPage, 
        colors);

    return Scaffold(
      backgroundColor: currentBgColor,
      body: Stack(
        children: [
          // Base Content (Current Slide)
          _buildSlideContent(_currentPage, colors),
          
          // Next Slide revealing over the base
          if (_isAnimatingTransition && _currentPage < _slides.length - 1)
            AnimatedBuilder(
              animation: _revealAnimation,
              builder: (context, child) {
                return ClipPath(
                  clipper: _CircularRevealClipper(
                    fraction: _revealAnimation.value,
                    center: _buttonPosition,
                  ),
                  child: Container(
                    color: nextBgColor,
                    child: _buildSlideContent(_currentPage + 1, colors),
                  ),
                );
              },
            ),

          // Foreground UI (always on top)
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/icons/logo2.png', height: 36),
                      TextButton(
                        onPressed: _skipOrComplete,
                        child: Text(
                          'Omitir',
                          style: TextStyle(
                            color: _getForegroundColor(_currentPage, colors).withOpacity(0.6),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom UI (FAB and Indicators)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == i ? 32 : 8,
                            decoration: BoxDecoration(
                              color: _getForegroundColor(_currentPage, colors).withOpacity(
                                _currentPage == i ? 1.0 : 0.3
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      // FAB Button
                      FloatingActionButton(
                        key: _buttonKey,
                        onPressed: _next,
                        elevation: 4,
                        backgroundColor: _getForegroundColor(_currentPage, colors),
                        foregroundColor: currentBgColor,
                        child: _currentPage == _slides.length - 1
                            ? const Icon(Icons.check_rounded, size: 28)
                            : const Icon(Icons.arrow_forward_rounded, size: 28),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideContent(int index, ColorScheme colors) {
    final slide = _slides[index];
    final fgColor = _getForegroundColor(index, colors);
    final bgColor = _getBackgroundColor(index, colors);

    // Apply a secondary slightly darker or lighter color for decorative orbs
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orbColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Stack(
      children: [
        // Decorative Orbs
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(shape: BoxShape.circle, color: orbColor),
          ),
        ),
        Positioned(
          bottom: 150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(shape: BoxShape.circle, color: orbColor),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                
                // Lottie Animation
                Expanded(
                  flex: 6,
                  child: Center(
                    child: Hero(
                      tag: 'lottie_animation_$index',
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: fgColor.withOpacity(0.05),
                        ),
                        child: Lottie.asset(
                          slide.lottiePath,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) => Icon(
                            Icons.error_outline,
                            size: 100,
                            color: fgColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),

                // Text
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        style: TextStyle(
                          color: fgColor,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        slide.description,
                        style: TextStyle(
                          color: fgColor.withOpacity(0.85),
                          fontSize: 17,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Circular Reveal Clipper ────────────────────────────────────────────────

class _CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset center;

  _CircularRevealClipper({required this.fraction, required this.center});

  @override
  Path getClip(Size size) {
    double maxRadius = _distanceToFarthestCorner(size, center);
    
    Path path = Path()
      ..addOval(Rect.fromCircle(
        center: center,
        radius: maxRadius * fraction,
      ));
    return path;
  }

  double _distanceToFarthestCorner(Size size, Offset center) {
    double distance(double x, double y) => math.sqrt(math.pow(center.dx - x, 2) + math.pow(center.dy - y, 2));
    return [
      distance(0, 0),
      distance(size.width, 0),
      distance(0, size.height),
      distance(size.width, size.height),
    ].reduce(math.max);
  }

  @override
  bool shouldReclip(_CircularRevealClipper oldClipper) => 
      fraction != oldClipper.fraction || center != oldClipper.center;
}
