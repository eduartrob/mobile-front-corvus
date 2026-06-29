import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/teams/presentation/widgets/team_member_card.dart';
import 'widgets/team_members_list.dart';
import 'widgets/team_ai_assistant_card.dart';
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

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.teamManagementTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.teamManagementDesc,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.teamFull,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '3/3',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            TeamMembersList(
              myAvatarUrl: myAvatarUrl,
              userName: user?.name,
              userEmail: user?.email,
            ),
            
            const SizedBox(height: 32),
            
            const TeamAiAssistantCard(),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _showUpcomingFeature(context, l10n),
                icon: const Icon(Icons.logout),
                label: Text(l10n.leaveTeam),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
