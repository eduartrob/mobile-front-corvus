import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/services/security_service.dart';
import 'package:lottie/lottie.dart';

// ─── Data ───────────────────────────────────────────────────────────────────

class _OnboardingSlideData {
  final String title;
  final String description;
  final String lottieUrl;

  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.lottieUrl,
  });
}

// ─── Page ───────────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final SecurityService _securityService = SecurityService();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Didi Brand Colors
  static const Color _didiOrange = Color(0xFFFC7B19);
  static const Color _darkText = Color(0xFF1A1A1A);
  static const Color _greyText = Color(0xFF666666);

  static const List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      title: 'Evaluación con Inteligencia Artificial',
      description: 'Analiza tus proyectos y propuestas académicas al instante con nuestra IA especializada.',
      // Public lottie URL for AI / Technology
      lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_zdturvzq.json', 
    ),
    _OnboardingSlideData(
      title: 'Equipos y Proyectos en un Solo Lugar',
      description: 'Gestiona el ciclo de vida completo de tu proyecto escolar y colabora con tu equipo fácilmente.',
      // Public lottie URL for Teamwork
      lottieUrl: 'https://assets3.lottiefiles.com/packages/lf20_q5pk6p1k.json',
    ),
    _OnboardingSlideData(
      title: 'Seguridad e Integridad Académica',
      description: 'Protección avanzada contra plagio para garantizar la originalidad de tus documentos.',
      // Public lottie URL for Security/Shield
      lottieUrl: 'https://assets8.lottiefiles.com/packages/lf20_6YgqUu.json',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _securityService.preventScreenshots(false);
    super.dispose();
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
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _skipOrComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOrComplete,
                    child: const Text(
                      'Omitir',
                      style: TextStyle(
                        color: _greyText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _slides.length,
                itemBuilder: (ctx, idx) => _SlideContent(data: _slides[idx]),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page Indicators (Dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == i ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i ? _didiOrange : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _didiOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1 ? 'Comenzar' : 'Siguiente',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

class _SlideContent extends StatelessWidget {
  final _OnboardingSlideData data;

  const _SlideContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation
          Expanded(
            flex: 6,
            child: Lottie.network(
              data.lottieUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback in case the public Lottie URL fails
                return const Center(
                  child: Icon(Icons.auto_awesome_mosaic, size: 100, color: Color(0xFFE0E0E0)),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),

          // Text content
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
