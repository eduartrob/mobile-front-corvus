import 'package:flutter/material.dart';
import 'package:mobile/core/theme/theme.dart';
import 'package:mobile/core/theme/util.dart';
import 'package:mobile/core/router/appRouter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Abel", "Jockey One");
    MaterialTheme theme = MaterialTheme(textTheme);
    
    ThemeData customDarkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF494BD6), // Azul índigo del diseño
        brightness: Brightness.dark,
        surface: const Color(0xFF0B1326), // Fondo profundo HTML
        surfaceContainer: const Color(0xFF171F33), // Tarjetas HTML
        surfaceContainerHigh: const Color(0xFF222A3D),
        surfaceContainerHighest: const Color(0xFF2D3449),
        primary: const Color(0xFFC0C1FF),
        onPrimary: const Color(0xFF1000A9),
        secondary: const Color(0xFFDDB7FF),
        secondaryContainer: const Color(0xFF6F00BE),
        tertiary: const Color(0xFF4FDBC8),
        tertiaryContainer: const Color(0xFF00A392),
        outlineVariant: const Color(0xFF464554),
      ),
      textTheme: textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1326),
    );
    
    return AppRouter(
      appTheme: customDarkTheme,
    );
  }
}
