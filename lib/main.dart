import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/app/app_bootstrap.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:mobile/core/services/network_service.dart';
import 'package:mobile/core/services/notification_navigation_service.dart';

import 'package:mobile/core/di/di.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/prof_profile/presentation/provider/linked_folders_provider.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'package:mobile/features/student_directory/presentation/provider/clustering_provider.dart';
import 'package:mobile/features/notifications/presentation/provider/notifications_provider.dart';
import 'package:mobile/features/prof_rules/presentation/provider/prof_rules_provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/core/services/firebase_messaging_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/profile/presentation/providers/saved_projects_provider.dart';
import 'package:mobile/features/prof_reviews/presentation/provider/prof_reviews_provider.dart';
import 'package:mobile/features/prof_dash/presentation/provider/prof_dash_provider.dart';
import 'package:mobile/features/prof_history/presentation/provider/prof_history_provider.dart';
import 'package:mobile/features/profile/presentation/provider/activity_history_provider.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Cargar variables de entorno ────────────────────────────────────────
  await dotenv.load(fileName: ".env");

  setupDependencies();
  NetworkService().initialize(globalMessengerKey);

  // ─── Dependencias async (SharedPreferences) ────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  setupAsyncDependencies(prefs);

  // ─── Providers desde el contenedor DI ───────────────────────────────────
  final authProvider = sl<AuthProvider>();
  final themeProvider = sl<ThemeProvider>();

  // ─── Inicialización en paralelo ────────────────────────────────────────
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
        .then((_) async {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(handleFCMMessage);

      // Tap en notificación desde background
      FirebaseMessaging.onMessageOpenedApp.listen(
        NotificationNavigationService.handle,
      );

      // App terminada y abierta desde notificación
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          Future.delayed(
            const Duration(milliseconds: 1500),
            () => NotificationNavigationService.handle(message),
          );
        }
      });
    }).catchError((_) {
      debugPrint('Firebase no inicializado: Ejecuta flutterfire configure');
    }),

    themeProvider.init(),
    authProvider.checkAuthStatus(),
    NotificationService().init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => sl<LinkedFoldersProvider>()),
        ChangeNotifierProvider(create: (_) => sl<MyProjectProvider>()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => sl<InspirationProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ProfRulesProvider>()),
        ChangeNotifierProvider(create: (_) => sl<TeamsProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ClusteringProvider>()),
        ChangeNotifierProvider(create: (_) => sl<NotificationsProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => sl<RegistrationProvider>()),
        ChangeNotifierProvider(create: (_) => sl<SavedProjectsProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ProfReviewsProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ProfHistoryProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ActivityHistoryProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ProfDashboardProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ProjectProvider>()),
      ],
      child: AppBootstrap(
        authProvider: authProvider,
        child: const MyApp(),
      ),
    ),
  );
}
