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
  final PageController _pageController = PageController();
  
  int _currentPage = 0;

  // Animation state for Circular Reveal
  bool _isRevealing = false;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;
  Offset _revealCenter = Offset.zero;
  int _targetPage = 0;

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
  }

  @override
  void dispose() {
    _revealController.dispose();
    _pageController.dispose();
    _securityService.preventScreenshots(false);
    super.dispose();
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

  void _triggerReveal(GlobalKey buttonKey, int nextPage) {
    if (_isRevealing) return;

    final RenderBox? renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      _revealCenter = Offset(
        position.dx + size.width / 2,
        position.dy + size.height / 2,
      );
    } else {
      // Fallback center if key not found
      final size = MediaQuery.of(context).size;
      _revealCenter = Offset(size.width / 2, size.height - 100);
    }

    setState(() {
      _targetPage = nextPage;
      _isRevealing = true;
    });

    _revealController.forward(from: 0.0).then((_) {
      // Instantly update the PageView underneath
      _pageController.jumpToPage(nextPage);
      setState(() {
        _currentPage = nextPage;
        _isRevealing = false;
      });
      _revealController.value = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: _getBackgroundColor(_currentPage, colors),
      body: Stack(
        children: [
          // 1. BASE: PageView for normal swiping
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              if (!_isRevealing) {
                setState(() => _currentPage = page);
              }
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return _buildSlideContent(index, colors);
            },
          ),

          // 2. OVERLAY: Circular Reveal (Only visible when button is pressed)
          if (_isRevealing)
            AnimatedBuilder(
              animation: _revealAnimation,
              builder: (context, child) {
                return ClipPath(
                  clipper: _CircularRevealClipper(
                    fraction: _revealAnimation.value,
                    center: _revealCenter,
                  ),
                  child: Container(
                    color: _getBackgroundColor(_targetPage, colors),
                    child: _buildSlideContent(_targetPage, colors),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSlideContent(int index, ColorScheme colors) {
    final slide = _slides[index];
    final fgColor = _getForegroundColor(index, colors);
    final bgColor = _getBackgroundColor(index, colors);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orbColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    
    // We create a unique key for the button in this slide so we can find its position
    final GlobalKey btnKey = GlobalKey();

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxHeight < 550 || constraints.maxWidth > constraints.maxHeight;
              if (isLandscape) {
                return _buildLandscapeLayout(index, slide, fgColor, bgColor, btnKey, constraints);
              } else {
                return _buildPortraitLayout(index, slide, fgColor, bgColor, btnKey, constraints);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(
    int index,
    _OnboardingSlideData slide,
    Color fgColor,
    Color bgColor,
    GlobalKey btnKey,
    BoxConstraints constraints,
  ) {
    return Column(
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
                    color: fgColor.withValues(alpha: 0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                
                // Lottie Animation
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: fgColor.withValues(alpha: 0.05),
                      ),
                      child: Lottie.asset(
                        slide.lottiePath,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => Icon(
                          Icons.error_outline,
                          size: 80,
                          color: fgColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Text
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.title,
                          style: TextStyle(
                            color: fgColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          style: TextStyle(
                            color: fgColor.withValues(alpha: 0.85),
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Dynamic Controls
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
          child: _buildDynamicControls(index, fgColor, bgColor, btnKey),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    int index,
    _OnboardingSlideData slide,
    Color fgColor,
    Color bgColor,
    GlobalKey btnKey,
    BoxConstraints constraints,
  ) {
    return Column(
      children: [
        // Compact Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/icons/logo2.png', height: 28),
              TextButton(
                onPressed: _skipOrComplete,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Omitir',
                  style: TextStyle(
                    color: fgColor.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Row side-by-side layout for Landscape
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                // Left: Lottie animation
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: fgColor.withValues(alpha: 0.05),
                      ),
                      child: Lottie.asset(
                        slide.lottiePath,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => Icon(
                          Icons.error_outline,
                          size: 60,
                          color: fgColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Right: Title, description, and controls
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slide.title,
                                style: TextStyle(
                                  color: fgColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                slide.description,
                                style: TextStyle(
                                  color: fgColor.withValues(alpha: 0.85),
                                  fontSize: 14,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: _buildDynamicControls(index, fgColor, bgColor, btnKey, isLandscape: true),
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

  Widget _buildDynamicControls(
      int index, Color fgColor, Color bgColor, GlobalKey btnKey, {bool isLandscape = false}) {
    final gapHeight = isLandscape ? 10.0 : 24.0;
    final btnSize = isLandscape ? 52.0 : 64.0;
    final wideBtnHeight = isLandscape ? 48.0 : 60.0;

    if (index == 0) {
      // Slide 1: Button Centered
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDots(index, fgColor),
          SizedBox(height: gapHeight),
          _AnimatedBounceButton(
            key: btnKey,
            onPressed: () => _triggerReveal(btnKey, 1),
            fgColor: fgColor,
            bgColor: bgColor,
            icon: Icons.arrow_downward_rounded,
            size: btnSize,
          ),
        ],
      );
    } else if (index == 1) {
      // Slide 2: Button on the Right
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDots(index, fgColor),
          _AnimatedBounceButton(
            key: btnKey,
            onPressed: () => _triggerReveal(btnKey, 2),
            fgColor: fgColor,
            bgColor: bgColor,
            icon: Icons.arrow_forward_rounded,
            size: btnSize,
          ),
        ],
      );
    } else {
      // Slide 3: Full Width Button
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDots(index, fgColor),
          SizedBox(height: gapHeight),
          _AnimatedWideButton(
            key: btnKey,
            onPressed: _skipOrComplete,
            fgColor: fgColor,
            bgColor: bgColor,
            text: 'Comenzar Aventura',
            height: wideBtnHeight,
          ),
        ],
      );
    }
  }

  Widget _buildDots(int index, Color fgColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: index == i ? 32 : 8,
          decoration: BoxDecoration(
            color: fgColor.withValues(alpha: index == i ? 1.0 : 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

// ─── Animated Buttons ────────────────────────────────────────────────────────

class _AnimatedBounceButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color fgColor;
  final Color bgColor;
  final IconData icon;
  final double size;

  const _AnimatedBounceButton({
    super.key,
    required this.onPressed,
    required this.fgColor,
    required this.bgColor,
    required this.icon,
    this.size = 64,
  });

  @override
  State<_AnimatedBounceButton> createState() => _AnimatedBounceButtonState();
}

class _AnimatedBounceButtonState extends State<_AnimatedBounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.fgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.fgColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(widget.icon, color: widget.bgColor, size: widget.size * 0.5),
        ),
      ),
    );
  }
}

class _AnimatedWideButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color fgColor;
  final Color bgColor;
  final String text;
  final double height;

  const _AnimatedWideButton({
    super.key,
    required this.onPressed,
    required this.fgColor,
    required this.bgColor,
    required this.text,
    this.height = 60,
  });

  @override
  State<_AnimatedWideButton> createState() => _AnimatedWideButtonState();
}

class _AnimatedWideButtonState extends State<_AnimatedWideButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.fgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.fgColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.bgColor,
              fontSize: widget.height > 50 ? 18 : 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
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
