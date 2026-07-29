import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThemePicker extends StatelessWidget {
  final Color selectedColor;
  final String selectedPattern;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<String> onPatternChanged;

  const ThemePicker({
    super.key,
    required this.selectedColor,
    required this.selectedPattern,
    required this.onColorChanged,
    required this.onPatternChanged,
  });

  static const List<Color> availableColors = [
    Color(0xFF4A90E2), // blue
    Color(0xFF50E3C2), // teal
    Color(0xFFB8E986), // light green
    Color(0xFF7ED321), // green
    Color(0xFFF8E71C), // yellow
    Color(0xFFF5A623), // orange
    Color(0xFFD0021B), // red
    Color(0xFFBD10E0), // purple
    Color(0xFF9013FE), // deep purple
    Color(0xFFFF8A80), // pink
    Color(0xFF8D6E63), // brown
    Color(0xFF607D8B), // blue grey
    Color(0xFF5C88DA), // muted blue
    Color(0xFF9A73C9), // muted purple
    Color(0xFF56A98A), // muted green
    Color(0xFFD98A53), // muted orange
    Color(0xFFD67389), // muted pink
  ];

  static final List<String> availablePatterns = List.generate(15, (index) => 'pattern_${index + 1}');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de Fondo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: availableColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final color = availableColors[index];
              final isSelected = color.value == selectedColor.value;
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2)]
                        : null,
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.black54) : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Diseño / Patrón',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: availablePatterns.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final pattern = availablePatterns[index];
              final isSelected = pattern == selectedPattern;
              return GestureDetector(
                onTap: () => onPatternChanged(pattern),
                child: Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: SvgPicture.asset(
                      'assets/patterns/$pattern.svg',
                      fit: BoxFit.none,
                      colorFilter: ColorFilter.mode(
                        ThemeData.estimateBrightnessForColor(selectedColor) == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.grey.shade700.withValues(alpha: 0.2),
                        BlendMode.srcATop,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
