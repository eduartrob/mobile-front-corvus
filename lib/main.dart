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
import 'package:mobile/features/my_project/data/my_project_remote_data_source.dart';
import 'package:mobile/features/my_project/data/my_project_local_data_source.dart';
import 'package:mobile/features/my_project/data/repositories/project_repository_impl.dart';
import 'package:mobile/features/my_project/domain/repositories/project_repository.dart';
import 'package:mobile/features/prof_dash/data/data_source/dashboard_remote_data_source.dart';
import 'package:mobile/features/prof_dash/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile/features/prof_dash/domain/repositories/dashboard_repository.dart';
import 'package:mobile/features/teams/data/data_source/teams_remote_data_source.dart';
import 'package:mobile/features/teams/data/repositories/teams_repository_impl.dart';
import 'package:mobile/features/teams/domain/repositories/teams_repository.dart';

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

    teamsProvider.fetchMyTeam().then((_) {
      final teamId = teamsProvider.myTeam?.id ?? '';
      myProjectProvider.init(uid, teamId);
    });

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

  // ─── Providers ──────────────────────────────────────────────────────────
  // Se crean todos los providers aquí pero SIN disparar llamadas API.
  // La carga de datos ocurre bajo demanda en cada pantalla.
  final authProvider = sl<AuthProvider>();
  final linkedFoldersProvider = LinkedFoldersProvider();

  // ── MyProject: Clean Architecture ────────────────────────────────────
  final projectRemoteDs = MyProjectRemoteDataSource(client: apiClient);
  final projectLocalDs = MyProjectLocalDataSource();
  final projectRepository = ProjectRepositoryImpl(
    remoteDataSource: projectRemoteDs,
    localDataSource: projectLocalDs,
  );
  final myProjectProvider = MyProjectProvider(repository: projectRepository);
  final themeProvider = ThemeProvider();
  final inspirationProvider = InspirationProvider();
  final profRulesProvider = ProfRulesProvider(
    remoteDataSource: ProfRulesRemoteDataSource(client: apiClient),
  );
  final notificationsProvider = NotificationsProvider();

  // ── Teams: Clean Architecture ────────────────────────────────────────
  final teamsRemoteDs = TeamsRemoteDataSource(client: apiClient);
  final teamsRepository = TeamsRepositoryImpl(remoteDataSource: teamsRemoteDs);
  final teamsProvider = TeamsProvider(repository: teamsRepository);
  final profileProvider = ProfileProvider();
  final profReviewsProvider = ProfReviewsProvider();
  final profHistoryProvider = ProfHistoryProvider(client: apiClient);

  final prefs = await SharedPreferences.getInstance();
  final savedProjectsRepo = SavedProjectsRepository(prefs);
  final savedProjectsProvider = SavedProjectsProvider(savedProjectsRepo);

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
        ChangeNotifierProvider(
            create: (_) {
              final dashDs = DashboardRemoteDataSource(client: apiClient);
              final dashRepo = DashboardRepositoryImpl(remoteDataSource: dashDs);
              return ProfDashboardProvider(
                authProvider: authProvider,
                repository: dashRepo,
              );
            }),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: _AppBootstrap(
        authProvider: authProvider,
        child: const MyApp(),
      ),
    ),
  );
}