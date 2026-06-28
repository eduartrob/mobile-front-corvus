import 'package:flutter/material.dart';
import 'package:mobile/core/theme/theme.dart';
import 'package:mobile/core/theme/util.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    TextTheme textTheme = createTextTheme(context, "Inter", "Outfit");
    MaterialTheme theme = MaterialTheme(textTheme);
    
    return AppRouter(
      appTheme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeProvider.themeMode,
    );
  }
}
