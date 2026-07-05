import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/auth/presentation/pages/login_page.dart';
import 'package:mobile/features/inspiration/presentation/pages/inspiration_page.dart';
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
import 'package:mobile/features/student_directory/presentation/pages/student_directory_page.dart';
import 'package:mobile/features/notifications/presentation/pages/notifications_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter extends StatelessWidget {
  final ThemeData? appTheme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;

  const AppRouter({super.key, this.appTheme, this.darkTheme, this.themeMode});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    final GoRouter router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      
      refreshListenable: authProvider,

      redirect: (context, state) {
        final authStatus = authProvider.status;
        final isGoingToLogin = state.matchedLocation == '/';

        // During active login (user pressed "Continuar con Google"), stay on login page.
        // At startup, checkAuthStatus() is awaited before runApp() so initial/loading
        // should not appear — but if it does, returning null is safe (stays where it is).
        if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
          return null;
        }

        if (authStatus != AuthStatus.authenticated && !isGoingToLogin) {
          return '/';
        }

        if (authStatus == AuthStatus.authenticated && isGoingToLogin) {
          if (authProvider.role == 'PROFESOR') {
            return '/prof-dash';
          }
          return '/inspiration';
        }

        return null;
      },

      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginPage(),
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
                  path: '/my-project',
                  builder: (context, state) => const MyProjectPage(),
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
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/teams',
                  builder: (context, state) => const TeamsPage(),
                ),
              ],
            ),
          ],
        ),

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ProfMainLayout(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/prof-dash',
                  builder: (context, state) => const ProfDashPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/prof-reviews',
                  builder: (context, state) => const ProfReviewsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/prof-rules',
                  builder: (context, state) => const ProfRulesPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/prof-history',
                  builder: (context, state) => const ProfHistoryPage(),
                ),
              ],
            ),
          ],
        ),
        
        GoRoute(
          path: '/prof-profile',
          builder: (context, state) => const ProfProfilePage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/activity-history',
          builder: (context, state) => const ActivityHistoryPage(),
        ),
        GoRoute(
          path: '/student-directory',
          builder: (context, state) => const StudentDirectoryPage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) {
            final highlightLatest = state.uri.queryParameters['highlightLatest'] == 'true';
            return NotificationsPage(highlightLatest: highlightLatest);
          },
        ),
        GoRoute(
          path: '/manage-team',
          builder: (context, state) => const ManageTeamPage(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Corvus',
      theme: appTheme ?? ThemeData.light(),
      darkTheme: darkTheme ?? ThemeData.dark(),
      themeMode: themeMode ?? ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}