import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/auth/presentation/pages/login_page.dart';
import 'package:mobile/features/auth/presentation/pages/register_page.dart';
import 'package:mobile/features/auth/presentation/pages/student_university_page.dart';
import 'package:mobile/features/auth/presentation/pages/student_skills_page.dart';
import 'package:mobile/features/auth/presentation/pages/teacher_verification_page.dart';
import 'package:mobile/features/auth/presentation/pages/teacher_info_page.dart';

import 'package:mobile/core/di/di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/auth/presentation/pages/onboarding_page.dart';

import 'package:mobile/features/inspiration/presentation/pages/inspiration_page.dart';
import 'package:mobile/features/my_project/presentation/pages/project_defense_chat_page.dart';
import 'package:mobile/features/my_project/presentation/pages/team_chat_page.dart';
import 'package:mobile/features/projects/presentation/pages/student_join_project_page.dart';
import 'package:mobile/features/projects/presentation/pages/student_qr_scanner_page.dart';
import 'package:mobile/features/projects/presentation/pages/prof_create_project_page.dart';

import 'package:mobile/features/my_project/presentation/pages/my_project_page.dart';
import 'package:mobile/features/teams/presentation/pages/teams_page.dart';
import 'package:mobile/features/teams/presentation/pages/manage_team_page.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/prof_dash/presentation/pages/prof_dash_page.dart';
import 'package:mobile/features/prof_reviews/presentation/pages/prof_reviews_page.dart';
import 'package:mobile/features/prof_rules/presentation/pages/prof_rules_page.dart';
import 'package:mobile/features/search/presentation/pages/search_page.dart';
import 'package:mobile/features/prof_history/presentation/pages/prof_history_page.dart';
import 'package:mobile/features/prof_profile/presentation/pages/prof_profile_page.dart';
import 'package:mobile/features/profile/presentation/pages/activity_history_page.dart';
import 'package:mobile/core/router/main_layout.dart';
import 'package:mobile/core/router/prof_main_layout.dart';
import 'package:mobile/core/router/project_layout.dart';
import 'package:mobile/core/router/prof_project_layout.dart';
import 'package:mobile/features/projects/presentation/pages/my_projects_dashboard_page.dart';
import 'package:mobile/features/projects/presentation/pages/prof_projects_dashboard_page.dart';
import 'package:mobile/features/prof_dash/presentation/pages/prof_directory_page.dart';
import 'package:mobile/features/projects/presentation/pages/prof_project_settings_page.dart';
import 'package:mobile/features/projects/presentation/pages/prof_project_config_page.dart';

import 'package:mobile/features/student_directory/presentation/pages/student_directory_page.dart';
import 'package:mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mobile/l10n/app_localizations.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Page _buildCupertinoTransition(Widget child, LocalKey key) {
  return CupertinoPage(
    key: key,
    child: child,
  );
}

Page _buildSlideUpTransition(Widget child, LocalKey key) {
  return CupertinoPage(
    key: key,
    child: child,
    fullscreenDialog: true,
  );
}
final GlobalKey<ScaffoldMessengerState> globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AppRouter extends StatefulWidget {
  final ThemeData? appTheme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;

  const AppRouter({super.key, this.appTheme, this.darkTheme, this.themeMode});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();

    _router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      
      refreshListenable: authProvider,

      redirect: (context, state) {
        final authStatus = authProvider.status;
        final isAuthRoute = state.matchedLocation == '/' || 
                            state.matchedLocation == '/login' || 
                            state.matchedLocation.startsWith('/register');

        // During active login (user pressed "Continuar con Google"), stay on login page.
        // At startup, checkAuthStatus() is awaited before runApp() so initial/loading
        // should not appear — but if it does, returning null is safe (stays where it is).
        if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
          return null;
        }

        if (authStatus != AuthStatus.authenticated && !isAuthRoute) {
          final prefs = sl<SharedPreferences>();
          final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
          if (!hasSeenOnboarding) {
            return '/welcome';
          }
          return '/login';
        }

        if (authStatus == AuthStatus.authenticated && isAuthRoute) {
          if (authProvider.role == 'PROFESOR' || authProvider.role == 'DOCENTE') {
            return '/prof-dash';
          }
          return '/inspiration';
        }

        return null;
      },

      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => '/login', // Fallback redirect if someone goes to /
        ),
        GoRoute(
          path: '/welcome',
          pageBuilder: (context, state) => _buildCupertinoTransition(const OnboardingPage(), state.pageKey),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) {
            final role = state.extra as String? ?? 'ALUMNO';
            return _buildSlideUpTransition(LoginPage(role: role), state.pageKey);
          },
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) {
            final role = state.extra as String? ?? 'ALUMNO';
            return _buildSlideUpTransition(RegisterPage(role: role), state.pageKey);
          },
        ),
        GoRoute(
          path: '/register-student-university',
          pageBuilder: (context, state) => _buildCupertinoTransition(const StudentUniversityPage(), state.pageKey),
        ),
        GoRoute(
          path: '/register-student-skills',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final skills = (extra['skills'] as List<dynamic>?)?.cast<String>() ?? [];
            return _buildCupertinoTransition(StudentSkillsPage(suggestedSkills: skills), state.pageKey);
          },
        ),
        GoRoute(
          path: '/join-project',
          pageBuilder: (context, state) => _buildSlideUpTransition(const StudentJoinProjectPage(), state.pageKey),
        ),
        GoRoute(
          path: '/student-qr-scanner',
          pageBuilder: (context, state) => _buildSlideUpTransition(const StudentQRScannerPage(), state.pageKey),
        ),
        GoRoute(
          path: '/prof-create-project',
          pageBuilder: (context, state) => _buildSlideUpTransition(const ProfCreateProjectPage(), state.pageKey),
        ),
        GoRoute(
          path: '/register-teacher-verification',
          pageBuilder: (context, state) => _buildCupertinoTransition(const TeacherVerificationPage(), state.pageKey),
        ),
        GoRoute(
          path: '/register-teacher-info',
          pageBuilder: (context, state) => _buildCupertinoTransition(const TeacherInfoPage(), state.pageKey),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainLayout(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/inspiration',
                  builder: (context, state) => const InspirationPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/projects',
                  builder: (context, state) => const MyProjectsDashboardPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) => const SearchPage(),
                ),
              ],
            ),
          ],
        ),

        // Nivel 2: Proyecto del Alumno
        // Usamos IndexedStack interno + query param 'tab' en lugar de
        // StatefulShellRoute para evitar el assertion error con rutas parametrizadas.
        GoRoute(
          path: '/project/:id',
          pageBuilder: (context, state) {
            final projectId = state.pathParameters['id']!;
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
            return _buildCupertinoTransition(
              ProjectLayout(projectId: projectId, initialTab: tab),
              state.pageKey,
            );
          },
        ),

        GoRoute(
          path: '/prof-dash',
          builder: (context, state) => const ProfProjectsDashboardPage(),
        ),

        // Nivel 2: Proyecto del Profesor
        GoRoute(
          path: '/prof-project/:projectId',
          pageBuilder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
            return _buildCupertinoTransition(
              ProfProjectLayout(projectId: projectId, initialTab: tab),
              state.pageKey,
            );
          },
        ),
        GoRoute(
          path: '/prof-project/:projectId/config',
          pageBuilder: (context, state) => _buildCupertinoTransition(
            ProfProjectConfigPage(projectId: state.pathParameters['projectId']!),
            state.pageKey,
          ),
        ),
        GoRoute(
          path: '/prof-project/:projectId/directory',
          pageBuilder: (context, state) => _buildCupertinoTransition(
            ProfDirectoryPage(projectId: state.pathParameters['projectId']!),
            state.pageKey,
          ),
        ),
        
        GoRoute(
          path: '/prof-profile',
          pageBuilder: (context, state) => _buildCupertinoTransition(const ProfProfilePage(), state.pageKey),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _buildCupertinoTransition(const ProfilePage(), state.pageKey),
        ),
        GoRoute(
          path: '/activity-history',
          pageBuilder: (context, state) => _buildCupertinoTransition(const ActivityHistoryPage(), state.pageKey),
        ),
        GoRoute(
          path: '/student-directory',
          pageBuilder: (context, state) => _buildCupertinoTransition(const StudentDirectoryPage(), state.pageKey),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) {
            final highlightLatest = state.uri.queryParameters['highlightLatest'] == 'true';
            return _buildCupertinoTransition(NotificationsPage(highlightLatest: highlightLatest), state.pageKey);
          },
        ),
        GoRoute(
          path: '/manage-team',
          pageBuilder: (context, state) => _buildCupertinoTransition(const ManageTeamPage(), state.pageKey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.id ?? 'no_auth';
    return MaterialApp.router(
      key: ValueKey(userId),
      debugShowCheckedModeBanner: false,
      title: 'Corvus',
      scaffoldMessengerKey: globalMessengerKey,
      theme: widget.appTheme ?? ThemeData.light(),
      darkTheme: widget.darkTheme ?? ThemeData.dark(),
      themeMode: widget.themeMode ?? ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      // Evita conflictos de Hero tags duplicados en SnackBars durante transiciones
      builder: (context, child) => HeroControllerScope.none(child: child!),
    );
  }
}

class _MockChatPage extends StatelessWidget {
  const _MockChatPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Text(l10n.chatUnderConstruction),
      ),
    );
  }
}
