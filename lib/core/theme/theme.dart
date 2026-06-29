import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1E40AF),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFDBEAFE),
      onPrimaryContainer: Color(0xFF00288E),
      
      secondary: Color(0xFF795900),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFFC329),
      onSecondaryContainer: Color(0xFF6F5100),
      
      tertiary: Color(0xFF323537),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF484C4E),
      onTertiaryContainer: Color(0xFFB9BCBE),
      
      error: Color(0xFFB91C1C),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      
      surface: Color(0xFFF8F9FF),
      onSurface: Color(0xFF0D1C2E),
      surfaceContainerHighest: Color(0xFFD5E3FC),
      surfaceContainer: Color(0xFFEFF4FF),
      surfaceContainerLow: Color(0xFFF8F9FF),
      onSurfaceVariant: Color(0xFF444653),
      
      outline: Color(0xFF94A3B8),
      outlineVariant: Color(0xFFC4C5D5),
      
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF233144),
      inversePrimary: Color(0xFFB8C4FF),
    );
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF6366F1),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF1E40AF),
      onPrimaryContainer: Color(0xFFDBEAFE),
      
      secondary: Color(0xFFF9BD22),
      onSecondary: Color(0xFF261A00),
      secondaryContainer: Color(0xFF5C4300),
      onSecondaryContainer: Color(0xFFFFC329),
      
      tertiary: Color(0xFFE0E3E5),
      onTertiary: Color(0xFF191C1E),
      tertiaryContainer: Color(0xFF323537),
      onTertiaryContainer: Color(0xFFE0E3E5),
      
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      
      surface: Color(0xFF0B1326),
      onSurface: Color(0xFFEAF1FF),
      surfaceContainerHighest: Color(0xFF31394D),
      surfaceContainer: Color(0xFF131B2E),
      surfaceContainerLow: Color(0xFF0B1326), 
      onSurfaceVariant: Color(0xFFB9BCBE),
      
      outline: Color(0xFF757684),
      outlineVariant: Color(0xFF475569),
      
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFF8F9FF),
      inversePrimary: Color(0xFF1E40AF),
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
     appBarTheme: AppBarTheme(
       backgroundColor: colorScheme.surface,
       foregroundColor: colorScheme.primary,
       elevation: 0,
       scrolledUnderElevation: 0,
     ),
  );

  ThemeData light() {
    return theme(lightScheme());
  }

  ThemeData dark() {
    return theme(darkScheme());
  }
}
