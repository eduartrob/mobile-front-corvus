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
    final orbColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    
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
                          color: fgColor.withOpacity(0.6),
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
                      const SizedBox(height: 20),
                      
                      // Lottie Animation
                      Expanded(
                        flex: 6,
                        child: Center(
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

              // Bottom Dynamic Controls
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: _buildDynamicControls(index, fgColor, bgColor, btnKey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicControls(
      int index, Color fgColor, Color bgColor, GlobalKey btnKey) {
    // Dynamic position logic based on slide index
    if (index == 0) {
      // Slide 1: Button Centered
      return Column(
        children: [
          _buildDots(index, fgColor),
          const SizedBox(height: 24),
          _AnimatedBounceButton(
            key: btnKey,
            onPressed: () => _triggerReveal(btnKey, 1),
            fgColor: fgColor,
            bgColor: bgColor,
            icon: Icons.arrow_downward_rounded,
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
          ),
        ],
      );
    } else {
      // Slide 3: Full Width Button
      return Column(
        children: [
          _buildDots(index, fgColor),
          const SizedBox(height: 24),
          _AnimatedWideButton(
            key: btnKey,
            onPressed: _skipOrComplete,
            fgColor: fgColor,
            bgColor: bgColor,
            text: 'Comenzar Aventura',
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
            color: fgColor.withOpacity(index == i ? 1.0 : 0.3),
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

  const _AnimatedBounceButton({
    super.key,
    required this.onPressed,
    required this.fgColor,
    required this.bgColor,
    required this.icon,
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
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: widget.fgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.fgColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(widget.icon, color: widget.bgColor, size: 32),
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

  const _AnimatedWideButton({
    super.key,
    required this.onPressed,
    required this.fgColor,
    required this.bgColor,
    required this.text,
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
          height: 60,
          decoration: BoxDecoration(
            color: widget.fgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.fgColor.withOpacity(0.3),
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
              fontSize: 18,
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
