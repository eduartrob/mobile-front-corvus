import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';

/// Pantalla de splash animada que se muestra una vez al iniciar.
/// La animación dura ~1.6s y luego navega a la pantalla correcta.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Logo: escala de 0.4 → 1.05 → 1.0 (efecto bounce suave)
  late Animation<double> _logoScale;
  // Logo: fade-in de 0 → 1
  late Animation<double> _logoOpacity;
  // Nombre "Corvus": fade-in tardío
  late Animation<double> _textOpacity;
  // Tagline: fade-in más tardío aún
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.4, end: 1.08), weight: 55),
      TweenSequenceItem(
          tween: Tween(begin: 1.08, end: 0.96), weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: 0.96, end: 1.0), weight: 25),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.90, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) => _navigateNext());
  }

  void _navigateNext() {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.status == AuthStatus.authenticated) {
      if (authProvider.role == 'PROFESOR') {
        context.go('/prof-dash');
      } else {
        context.go('/inspiration');
      }
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Logo animado ──────────────────────────────────
            AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Nombre "Corvus" ───────────────────────────────
            AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Opacity(
                opacity: _textOpacity.value,
                child: const Text(
                  'Corvus',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Tagline ───────────────────────────────────────
            AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Opacity(
                opacity: _taglineOpacity.value,
                child: const Text(
                  'Validación académica inteligente',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
