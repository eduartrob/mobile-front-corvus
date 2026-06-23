import 'package:flutter/material.dart';
import 'package:mobile/core/theme/theme.dart';
import 'package:mobile/core/theme/util.dart';
import 'package:mobile/core/router/appRouter.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;
  
  const MyApp({super.key, this.initialRoute = '/'});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Abel", "Jockey One");
    MaterialTheme theme = MaterialTheme(textTheme);
    
    return AppRouter(
      appTheme: theme.dark(),
      initialRoute: initialRoute,
    );
  }
}
