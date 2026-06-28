import 'package:flutter/material.dart';
import 'package:mobile/app.dart';

import 'package:mobile/core/di/di.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/prof_profile/presentation/provider/linked_folders_provider.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/core/services/firebase_messaging_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (Requiere flutterfire configure previo)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(handleFCMMessage);
  } catch (e) {
    debugPrint('Firebase no inicializado: Ejecuta flutterfire configure');
  }

  // Inicializar inyección de dependencias (síncrono, rápido)
  setupDependencies();

  // Crear providers globales
  final authProvider = sl<AuthProvider>();
  final linkedFoldersProvider = LinkedFoldersProvider();
  
  final themeProvider = ThemeProvider();
  await themeProvider.init();

  // ARRANCAR LA APP DE INMEDIATO — sin esperar red ni storage
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: linkedFoldersProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => InspirationProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // Inicializar Notificaciones EN SEGUNDO PLANO (no bloquea el primer frame)
  NotificationService().init();

  // Verificar sesión guardada de forma asíncrona — la UI maneja el estado loading
  authProvider.checkAuthStatus().then((_) {
    final jwtToken = authProvider.currentUser?.token;
    if (jwtToken != null) {
      linkedFoldersProvider.loadFolders(jwtToken);
    }
  });
}
