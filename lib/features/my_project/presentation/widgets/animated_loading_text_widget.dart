import 'package:flutter/material.dart';

class AnimatedLoadingTextWidget extends StatefulWidget {
  const AnimatedLoadingTextWidget({super.key});

  @override
  State<AnimatedLoadingTextWidget> createState() => _AnimatedLoadingTextWidgetState();
}

class _AnimatedLoadingTextWidgetState extends State<AnimatedLoadingTextWidget> {
  final List<Map<String, dynamic>> _phases = [
    {'icon': '📄', 'text': 'Extrayendo el contenido de tu manuscrito...'},
    {'icon': '🔍', 'text': 'Limpiando y anonimizando el texto...'},
    {'icon': '🧠', 'text': 'Vectorizando el contenido con IA semántica...'},
    {'icon': '📚', 'text': 'Buscando proyectos similares en el repositorio histórico...'},
    {'icon': '⚖️', 'text': 'Calculando el riesgo de colisión semántica...'},
    {'icon': '✍️', 'text': 'El comité académico está redactando el dictamen...'},
    {'icon': '💡', 'text': 'Generando recomendaciones técnicas personalizadas...'},
    {'icon': '🏁', 'text': 'Afinando el veredicto final, casi listo...'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 12), (i) => i % _phases.length),
      initialData: 0,
      builder: (context, snapshot) {
        final index = snapshot.data ?? 0;
        final phase = _phases[index];
        return Column(
          children: [
            // Indicador de fase (puntos)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_phases.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == index 
                    ? colorScheme.primary 
                    : colorScheme.primary.withOpacity(0.25),
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
                key: ValueKey<int>(index),
                children: [
                  Text(
                    phase['icon']!,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fase ${index + 1} de ${_phases.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      phase['text']!,
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
                    'El análisis puede tardar entre 30 y 90 segundos\ndependiendo del modelo de IA del servidor.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.45),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
