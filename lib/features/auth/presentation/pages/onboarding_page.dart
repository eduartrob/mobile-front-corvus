import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/services/security_service.dart';

// ─── Data ───────────────────────────────────────────────────────────────────

class _OnboardingSlideData {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final Color bgColor;
  final Color accentColor;

  const _OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.bgColor,
    required this.accentColor,
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

  late AnimationController _bgController;
  late Animation<Color?> _bgColorAnim;

  late AnimationController _orbController;
  late Animation<double> _orbAnimation;

  static const List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      title: 'EVALÚA CON\nINTELIGENCIA\nARTIFICIAL.',
      subtitle: 'Análisis de Propuestas con IA',
      description: 'Sube tu propuesta y obtén retroalimentación instantánea impulsada por IA.',
      imagePath: 'assets/images/onboarding_1.png',
      bgColor: Color(0xFF0A1929),
      accentColor: Color(0xFF00B8D9),
    ),
    _OnboardingSlideData(
      title: 'CONSTRUYE\nTU EQUIPO\nPERFECTO.',
      subtitle: 'Gestión de Equipos',
      description: 'Forma tu equipo, asigna roles y gestiona todo tu proyecto desde un solo lugar.',
      imagePath: 'assets/images/onboarding_2.png',
      bgColor: Color(0xFF1A0A00),
      accentColor: Color(0xFFFF6B00),
    ),
    _OnboardingSlideData(
      title: 'INTEGRIDAD\nACONDÉMICA\nGARANTIZADA.',
      subtitle: 'Seguridad Anti-Plagio',
      description: 'Sistema inteligente de detección de similitudes para proteger la originalidad de tu trabajo.',
      imagePath: 'assets/images/onboarding_3.png',
      bgColor: Color(0xFF0D0020),
      accentColor: Color(0xFF7C3AED),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bgColorAnim = ColorTween(
      begin: _slides[0].bgColor,
      end: _slides[0].bgColor,
    ).animate(_bgController);

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _orbAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    _orbController.dispose();
    _securityService.preventScreenshots(false);
    super.dispose();
  }

  void _onPageChanged(int page) {
    final prevColor = _slides[_currentPage].bgColor;
    final nextColor = _slides[page].bgColor;

    _bgColorAnim = ColorTween(
      begin: prevColor,
      end: nextColor,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _bgController.forward(from: 0);
    setState(() => _currentPage = page);
  }

  Future<void> _skipOrComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    context.go('/login');
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _skipOrComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentSlide = _slides[_currentPage];

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgColorAnim,
        builder: (context, child) {
          final bg = _bgColorAnim.value ?? currentSlide.bgColor;
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: bg,
            child: child,
          );
        },
        child: Stack(
          children: [
            // — Decorative animated orbs —
            AnimatedBuilder(
              animation: _orbAnimation,
              builder: (context, _) {
                final accent = currentSlide.accentColor;
                return Stack(
                  children: [
                    Positioned(
                      top: -size.width * 0.3 + _orbAnimation.value * 30,
                      right: -size.width * 0.2,
                      child: _GlowOrb(
                        size: size.width * 0.8,
                        color: accent.withOpacity(0.15),
                      ),
                    ),
                    Positioned(
                      bottom: size.height * 0.2 - _orbAnimation.value * 20,
                      left: -size.width * 0.3,
                      child: _GlowOrb(
                        size: size.width * 0.7,
                        color: accent.withOpacity(0.10),
                      ),
                    ),
                  ],
                );
              },
            ),

            // — Content: PageView —
            SafeArea(
              child: Column(
                children: [
                  // Top bar: logo + skip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/icons/logo2.png', height: 32),
                        TextButton(
                          onPressed: _skipOrComplete,
                          child: Text(
                            'Saltar',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Slide content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _slides.length,
                      itemBuilder: (ctx, idx) => _SlideContent(
                        data: _slides[idx],
                        isActive: idx == _currentPage,
                      ),
                    ),
                  ),

                  // Bottom controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Dots
                        Row(
                          children: List.generate(
                            _slides.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.only(right: 8),
                              height: 6,
                              width: _currentPage == i ? 28 : 6,
                              decoration: BoxDecoration(
                                color: _currentPage == i
                                    ? currentSlide.accentColor
                                    : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        // Next / Start button
                        AnimatedBuilder(
                          animation: _orbController,
                          builder: (ctx, _) => _NextButton(
                            isLast: _currentPage == _slides.length - 1,
                            accentColor: currentSlide.accentColor,
                            onTap: _next,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Slide Content ──────────────────────────────────────────────────────────

class _SlideContent extends StatefulWidget {
  final _OnboardingSlideData data;
  final bool isActive;
  const _SlideContent({required this.data, required this.isActive});

  @override
  State<_SlideContent> createState() => _SlideContentState();
}

class _SlideContentState extends State<_SlideContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slideImg;
  late Animation<Offset> _slideText;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5)),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );
    _slideImg = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)));
    _slideText = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic)));

    if (widget.isActive) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_SlideContent old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.forward(from: 0);
    } else if (!widget.isActive) {
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.data.accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Illustration ─
          Expanded(
            flex: 5,
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slideImg,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.25),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          widget.data.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ─ Text Block ─
          Expanded(
            flex: 4,
            child: SlideTransition(
              position: _slideText,
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Accent chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        widget.data.subtitle,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Big title
                    Text(
                      widget.data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      widget.data.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Next button ────────────────────────────────────────────────────────────

class _NextButton extends StatefulWidget {
  final bool isLast;
  final Color accentColor;
  final VoidCallback onTap;

  const _NextButton({
    required this.isLast,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton>
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
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
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
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: widget.isLast
              ? const EdgeInsets.symmetric(horizontal: 28, vertical: 16)
              : const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.accentColor,
            borderRadius: BorderRadius.circular(widget.isLast ? 50 : 50),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.isLast
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Comenzar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                )
              : const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ─── Glow Orb ────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
