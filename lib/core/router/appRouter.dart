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
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/prof_dash/presentation/pages/prof_dash_page.dart';
import 'package:mobile/features/prof_reviews/presentation/pages/prof_reviews_page.dart';
import 'package:mobile/features/prof_rules/presentation/pages/prof_rules_page.dart';
import 'package:mobile/features/prof_history/presentation/pages/prof_history_page.dart';
import 'package:mobile/features/prof_profile/presentation/pages/prof_profile_page.dart';
import 'package:mobile/core/router/main_layout.dart';
import 'package:mobile/core/router/prof_main_layout.dart';

class AppRouter extends StatelessWidget {
  final ThemeData? appTheme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;

  const AppRouter({super.key, this.appTheme, this.darkTheme, this.themeMode});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    final GoRouter router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      
      refreshListenable: authProvider,

      redirect: (context, state) {
        final authStatus = authProvider.status;
        final isGoingToLogin = state.matchedLocation == '/';

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
                  path: '/teams',
                  builder: (context, state) => const TeamsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfilePage(),
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