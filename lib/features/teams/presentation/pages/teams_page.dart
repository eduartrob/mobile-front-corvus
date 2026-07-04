import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import '../widgets/equipo_tab.dart';
import '../widgets/solicitudes_tab.dart';
import '../widgets/sugerencias_tab.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  void _showUpcomingFeature(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureUpcoming),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;
    final myAvatarUrl = user?.photoUrl ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuD0wLXmNJdheSLYRV0cyw58WRptbP7Tcpj2DYe6d6sJQiytU6tgetCYTsh4-Ov0geC0LLapbMasxnzTMELIMNsnayUh4N9TGK5De10d2W71dWF73JXTBHyjaWFa07BYB77_vkOYSDrr-SvtGzREIK2cHWLZNpEc3oBxuPIFF5-lfeKEPSrbyfJCy2PIjLahEVgXVyF24D6pU3BzhZ6AQHJgFgzuPc1CohlsoHoMho2D-B73NSq78KXkdfio1LlxfaQz9d9DTHm2BG0';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const CorvusTopBar(),
        body: Column(
          children: [
            // TabBar container
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.4),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                labelColor: colorScheme.onSurface,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                unselectedLabelColor: colorScheme.onSurfaceVariant.withOpacity(0.7),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Equipo'),
                  Tab(text: 'Solicitudes'),
                  Tab(text: 'Sugerencias'),
                ],
              ),
            ),
            // Tab contents
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Equipo
                  EquipoTab(
                    myAvatarUrl: myAvatarUrl,
                    userName: user?.name,
                    userEmail: user?.email,
                    onLeaveTeam: () => _showUpcomingFeature(context, l10n),
                  ),
                  // Tab 2: Solicitudes
                  const SolicitudesTab(),
                  // Tab 3: Sugerencias
                  const SugerenciasTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
