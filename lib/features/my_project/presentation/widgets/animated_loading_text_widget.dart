import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';

class AnimatedLoadingTextWidget extends StatelessWidget {
  const AnimatedLoadingTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<MyProjectProvider>();

    final List<Map<String, String>> defaultPhases = [
      {'icon': '📄', 'text': l10n.loadingPhase1},
      {'icon': '🔍', 'text': l10n.loadingPhase2},
      {'icon': '🧠', 'text': l10n.loadingPhase3},
      {'icon': '📚', 'text': l10n.loadingPhase4},
      {'icon': '⚖️', 'text': l10n.loadingPhase5},
      {'icon': '✍️', 'text': l10n.loadingPhase6},
      {'icon': '💡', 'text': l10n.loadingPhase7},
      {'icon': '🏁', 'text': l10n.loadingPhase8},
    ];

    // La fase reportada por el servidor (entre 1 y 8)
    final serverPhase = provider.serverPhase;
    final index = (serverPhase - 1).clamp(0, defaultPhases.length - 1);
    final phaseData = defaultPhases[index];

    // Si el servidor envía un mensaje personalizado (ej. "En cola de espera..."), lo mostramos
    final displayText = provider.serverPhaseMessage.isNotEmpty 
        ? provider.serverPhaseMessage 
        : phaseData['text']!;

    return Column(
      children: [
        // Indicador de fase (puntos sincronizados con el servidor)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(defaultPhases.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index 
                ? colorScheme.primary 
                : colorScheme.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey<String>('$index-$displayText'),
            children: [
              Text(
                phaseData['icon']!,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 10),
              Text(
                'Fase ${index + 1} de ${defaultPhases.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.analysisEstimatedTime,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
