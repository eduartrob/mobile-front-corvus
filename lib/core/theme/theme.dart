import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      // Primary: azul lavanda pastel
      primary: Color(0xFF6B7CE8),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE3E7FB),
      onPrimaryContainer: Color(0xFF1E2868),

      // Secondary: gris cálido pastel
      secondary: Color(0xFF9CA3B8),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFEAE7DE),
      onSecondaryContainer: Color(0xFF1A1A1A),

      // Tertiary: durazno pastel (acento cálido)
      tertiary: Color(0xFFE89B6C),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFAE0CE),
      onTertiaryContainer: Color(0xFF4A2510),

      // Acento menta pastel
      secondaryFixed: Color(0xFF7FC4A8),
      onSecondaryFixed: Color(0xFFFFFFFF),
      secondaryFixedDim: Color(0xFFD1F0E1),
      onSecondaryFixedVariant: Color(0xFF0E3D2A),

      // Acento lavanda pastel
      tertiaryFixed: Color(0xFFB8A0D9),
      onTertiaryFixed: Color(0xFFFFFFFF),
      tertiaryFixedDim: Color(0xFFEAE0F7),
      onTertiaryFixedVariant: Color(0xFF352570),

      // Error coral pastel (no rojo saturado)
      error: Color(0xFFE57373),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFE0DE),
      onErrorContainer: Color(0xFF7A1F1F),

      // Fondo blanco neutro
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A1A1A),
      surfaceContainerHighest: Color(0xFFE8E8E8),
      surfaceContainerHigh: Color(0xFFF0F0F0),
      surfaceContainer: Color(0xFFF5F5F5),
      surfaceContainerLow: Color(0xFFFAFAFA),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFF5C5C5C),

      outline: Color(0xFFD8D4C7),
      outlineVariant: Color(0xFFE5E2D6),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF1A1A1A),
      inversePrimary: Color(0xFFB8C4F0),
    );
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF93C5FD),
      onPrimary: Color(0xFF0F172A),
      primaryContainer: Color(0xFF1E3A8A),
      onPrimaryContainer: Color(0xFFDBEAFE),

      secondary: Color(0xFF94A3B8),
      onSecondary: Color(0xFF0F172A),
      secondaryContainer: Color(0xFF334155),
      onSecondaryContainer: Color(0xFFF1F5F9),

      tertiary: Color(0xFF6DD5C3),
      onTertiary: Color(0xFF0F172A),
      tertiaryContainer: Color(0xFF115E59),
      onTertiaryContainer: Color(0xFFCCFBF1),

      error: Color(0xFFFCA5A5),
      onError: Color(0xFF450A0A),
      errorContainer: Color(0xFF991B1B),
      onErrorContainer: Color(0xFFFFE4E1),

      surface: Color(0xFF0F172A),
      onSurface: Color(0xFFF8FAFC),
      surfaceContainerHighest: Color(0xFF475569),
      surfaceContainerHigh: Color(0xFF475569),
      surfaceContainer: Color(0xFF334155),
      surfaceContainerLow: Color(0xFF1E293B),
      surfaceContainerLowest: Color(0xFF0B1120),
      onSurfaceVariant: Color(0xFF94A3B8),

      outline: Color(0xFF475569),
      outlineVariant: Color(0xFF334155),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFF8FAFC),
      inversePrimary: Color(0xFF6B7CE8),
    );
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     fontFamily: 'Inter',
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
       fontFamily: 'Inter',
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
     dividerTheme: DividerThemeData(
       color: colorScheme.outlineVariant,
       space: 1,
       thickness: 1,
     ),
     cardTheme: CardThemeData(
       color: colorScheme.surfaceContainerLow,
       elevation: 0,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(20),
       ),
     ),
     appBarTheme: AppBarTheme(
       backgroundColor: colorScheme.surface,
       foregroundColor: colorScheme.onSurface,
       elevation: 0,
       scrolledUnderElevation: 0,
     ),
     bottomNavigationBarTheme: BottomNavigationBarThemeData(
       backgroundColor: colorScheme.surfaceContainerLowest,
       elevation: 0,
       selectedItemColor: colorScheme.onPrimaryContainer,
       unselectedItemColor: colorScheme.onSurfaceVariant,
       type: BottomNavigationBarType.fixed,
     ),
  );

  ThemeData light() {
    return theme(lightScheme());
  }

  ThemeData dark() {
    return theme(darkScheme());
  }
}