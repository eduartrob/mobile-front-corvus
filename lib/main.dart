import 'package:flutter/material.dart';
import 'package:mobile/src/plugin/theme/theme.dart';
import 'package:mobile/src/plugin/theme/util.dart';
import 'package:mobile/src/router/appRouter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Abel", "Jockey One");

    MaterialTheme theme = MaterialTheme(textTheme);
    return AppRouter(
      appTheme: brightness == Brightness.light ? theme.light() : theme.dark(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
    );
  }
}
