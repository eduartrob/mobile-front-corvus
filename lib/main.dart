import 'package:flutter/material.dart';
import 'package:mobile/app.dart';

import 'package:mobile/core/di/di.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/prof_profile/presentation/provider/linked_folders_provider.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/teams/presentation/provider/solicitudes_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/core/services/firebase_messaging_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Inicialización en paralelo ────────────────────────────────────────────
  // Los tres procesos arrancan al mismo tiempo. El tiempo de espera total es
  // igual al más lento (~500ms), en lugar de la suma de los tres (~750ms).
  setupDependencies();

  final authProvider = sl<AuthProvider>();
  final linkedFoldersProvider = LinkedFoldersProvider();
  final myProjectProvider = MyProjectProvider();
  final themeProvider = ThemeProvider();

  await Future.wait([
    // Firebase: ~200-500ms (conexión a servidores de Google)
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
        .then((_) async {
          FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
          FirebaseMessaging.onMessage.listen(handleFCMMessage);
          await FirebaseMessaging.instance.subscribeToTopic('config_updates');
        })
        .catchError((_) {
          debugPrint('Firebase no inicializado: Ejecuta flutterfire configure');
        }),

    // Tema: ~50ms (lee SharedPreferences)
    themeProvider.init(),

    // Auth: ~100-200ms (lee Secure Storage del dispositivo)
    authProvider.checkAuthStatus(),

    // Notificaciones: registro de canales en Android
    NotificationService().init(),
  ]);
  // ───────────────────────────────────────────────────────────────────────────

  // If already authenticated (stored session), preload data immediately
  final userId = authProvider.currentUser?.id;
  if (userId != null) {
    myProjectProvider.init(userId);
    final jwtToken = authProvider.currentUser?.token;
    if (jwtToken != null) {
      linkedFoldersProvider.loadFolders(jwtToken);
    }
  }

  // Listen for fresh logins (e.g. user presses "Continuar con Google")
  // so providers initialize even when there was no stored session at startup.
  authProvider.addListener(() {
    if (authProvider.status == AuthStatus.authenticated) {
      final uid = authProvider.currentUser?.id;
      if (uid != null) {
        myProjectProvider.init(uid); // init() has an _initialized guard; safe to call
        final token = authProvider.currentUser?.token;
        if (token != null) {
          linkedFoldersProvider.loadFolders(token);
        }
      }
    }
  });


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: linkedFoldersProvider),
        ChangeNotifierProvider.value(value: myProjectProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => InspirationProvider()),
        ChangeNotifierProvider(create: (_) => SolicitudesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
