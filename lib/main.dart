import 'package:flutter/material.dart';
import 'package:mobile/app.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/appRouter.dart';

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
import 'package:mobile/features/prof_rules/data/data_source/prof_rules_remote_data_source.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/core/services/firebase_messaging_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/profile/data/repositories/saved_projects_repository.dart';
import 'package:mobile/features/profile/presentation/providers/saved_projects_provider.dart';
import 'package:mobile/features/prof_reviews/presentation/provider/prof_reviews_provider.dart';
import 'package:mobile/features/prof_dash/presentation/provider/prof_dash_provider.dart';
import 'package:mobile/features/prof_history/presentation/provider/prof_history_provider.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';

void _handleNotificationTap(RemoteMessage message) {
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    if (message.data['type'] == 'TEAM_INVITE') {
      context.push('/teams?tab=1'); // tab 1 is Solicitudes
    } else {
      context.push('/notifications?highlightLatest=true');
    }
  }
}

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
  final inspirationProvider = InspirationProvider();
  final profRulesProvider = ProfRulesProvider(
    remoteDataSource: ProfRulesRemoteDataSource(client: apiClient),
  );
  final notificationsProvider = NotificationsProvider()..fetchNotifications();
  final teamsProvider = TeamsProvider();
  final profileProvider = ProfileProvider();
  final profReviewsProvider = ProfReviewsProvider();
  final profHistoryProvider = ProfHistoryProvider(client: apiClient);
  
  final prefs = await SharedPreferences.getInstance();
  final savedProjectsRepo = SavedProjectsRepository(prefs);
  final savedProjectsProvider = SavedProjectsProvider(savedProjectsRepo);

  await Future.wait([
    // Firebase: ~200-500ms (conexión a servidores de Google)
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
        .then((_) async {
          FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
          FirebaseMessaging.onMessage.listen(handleFCMMessage);
          
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
            _handleNotificationTap(message);
          });
          
          FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
            if (message != null) {
              Future.delayed(const Duration(milliseconds: 1500), () {
                _handleNotificationTap(message);
              });
            }
          });

          // La suscripción a 'config_updates' ahora se maneja en el listener de authProvider
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
    if (authProvider.currentUser?.role == 'student') {
      FirebaseMessaging.instance.subscribeToTopic('config_updates');
    } else {
      FirebaseMessaging.instance.unsubscribeFromTopic('config_updates');
    }
    
    inspirationProvider.loadProjects(forceRefresh: true);
    profRulesProvider.fetchData();
    teamsProvider.fetchMyTeam();
    profileProvider.fetchProfile();
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
        if (authProvider.currentUser?.role == 'student') {
          FirebaseMessaging.instance.subscribeToTopic('config_updates');
        } else {
          FirebaseMessaging.instance.unsubscribeFromTopic('config_updates');
        }
        
        inspirationProvider.loadProjects(forceRefresh: true);
        profRulesProvider.fetchData();
        profHistoryProvider.fetchHistory();
        notificationsProvider.fetchNotifications(); // Recargar notificaciones al cambiar a alumno
        teamsProvider.fetchMyTeam();
        profileProvider.fetchProfile();
      }
    } else {
      FirebaseMessaging.instance.unsubscribeFromTopic('config_updates');
    }
  });


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: linkedFoldersProvider),
        ChangeNotifierProvider.value(value: myProjectProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: inspirationProvider),
        ChangeNotifierProvider.value(value: profRulesProvider),
        ChangeNotifierProvider.value(value: teamsProvider),
        ChangeNotifierProvider(create: (_) => ClusteringProvider()),
        ChangeNotifierProvider.value(value: notificationsProvider),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider.value(value: savedProjectsProvider),
        ChangeNotifierProvider.value(value: profReviewsProvider),
        ChangeNotifierProvider.value(value: profHistoryProvider),
        ChangeNotifierProvider(create: (_) => ProfDashboardProvider(authProvider: authProvider)),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
