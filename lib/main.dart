import 'package:flutter/material.dart';
import 'package:mobile/app.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:mobile/core/services/network_service.dart';

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
import 'package:mobile/core/network/auth_interceptor_client.dart';
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

/// Handler para taps en notificaciones cuando la app está en background/terminada.
void _handleNotificationTap(RemoteMessage message) {
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    if (message.data['type'] == 'TEAM_INVITE') {
      final myProjects = context.read<ProjectProvider>().myProjects;
      final projectId = message.data['projectId'] ??
          (myProjects.isNotEmpty ? myProjects.first['id'] : null);

      if (projectId != null) {
        context.push('/project/$projectId?tab=1');
      } else {
        context.push('/inspiration');
      }
    } else {
      context.push('/notifications?highlightLatest=true');
    }
  }
}

/// Widget raíz que escucha cambios de autenticación y dispara la carga
/// de datos esenciales solo cuando el usuario está autenticado.
///
/// Esto reemplaza el `authProvider.addListener` en main() y evita cargar
/// datos masivamente durante el arranque.
class _AppBootstrap extends StatefulWidget {
  final AuthProvider authProvider;
  final Widget child;

  const _AppBootstrap({required this.authProvider, required this.child});

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _wasAuthenticated =
        widget.authProvider.status == AuthStatus.authenticated;
    widget.authProvider.addListener(_onAuthChanged);

    // Si ya está autenticado al arrancar, cargar solo lo esencial
    if (_wasAuthenticated) {
      _loadEssentialData();
    }
  }

  @override
  void dispose() {
    widget.authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final isAuth =
        widget.authProvider.status == AuthStatus.authenticated;
    if (isAuth && !_wasAuthenticated) {
      _wasAuthenticated = true;
      _loadEssentialData();
    } else if (!isAuth) {
      _wasAuthenticated = false;
      // Limpiar todos los providers para evitar fugas de estado entre sesiones
      try { context.read<MyProjectProvider>().reset(''); } catch (_) {}
      try { context.read<TeamsProvider>().clear(); } catch (_) {}
      try { context.read<ProfileProvider>().clear(); } catch (_) {}
      try { context.read<ProjectProvider>().clear(); } catch (_) {}
      try { context.read<InspirationProvider>().clear(); } catch (_) {}
      try { context.read<NotificationsProvider>().clear(); } catch (_) {}
      try { context.read<ProfDashboardProvider>().clear(); } catch (_) {}
      FirebaseMessaging.instance.unsubscribeFromTopic('config_updates');
    }
  }

  /// Carga solo los datos esenciales para que la app funcione.
  /// El resto de features cargan bajo demanda cuando el usuario
  /// visita cada pantalla (lazy loading).
  void _loadEssentialData() {
    final uid = widget.authProvider.currentUser?.id;
    if (uid == null) return;

    // Solo cargar teams (necesario para saber si tiene equipo) y
    // suscribirse a tópicos FCM. El resto se carga on-demand.
    final teamsProvider = context.read<TeamsProvider>();
    final myProjectProvider = context.read<MyProjectProvider>();
    final profileProvider = context.read<ProfileProvider>();

    teamsProvider.fetchMyTeam().then((_) {
      final teamId = teamsProvider.myTeam?.id ?? '';
      myProjectProvider.init(uid, teamId);
    });

    profileProvider.fetchProfile();
    final projectProvider = context.read<ProjectProvider>();
    final token = widget.authProvider.currentUser?.token;
    if (token != null) projectProvider.loadMyProjects(token, quiet: true, userId: uid);

    // Configurar userId en InspirationProvider para namespacear SharedPreferences
    context.read<InspirationProvider>().setUserId(uid);

    final role = widget.authProvider.currentUser?.role;
    if (role == 'student') {
      FirebaseMessaging.instance.subscribeToTopic('config_updates');
    } else {
      FirebaseMessaging.instance.unsubscribeFromTopic('config_updates');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(handleFCMMessage);

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message);
      });

      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            _handleNotificationTap(message);
          });
        }
      });
    }).catchError((_) {
      debugPrint(
          'Firebase no inicializado: Ejecuta flutterfire configure');
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
      child: _AppBootstrap(
        authProvider: authProvider,
        child: const MyApp(),
      ),
    ),
  );
}