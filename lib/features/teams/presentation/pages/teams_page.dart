import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/corvus_top_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              'Gestión de Equipo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Proyecto Final: "Implementación de RAG para Análisis Documental". Administra los miembros de tu grupo de investigación.',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Badge Equipo Completo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.15),
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
                    'Equipo Completo',
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
            
            // Header Integrantes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Integrantes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Gestionar'),
                  style: TextButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lista de Integrantes
            _buildMemberCard(
              context,
              avatarUrl: myAvatarUrl,
              name: user?.name ?? 'Alex Rivera',
              email: user?.email ?? 'arivera@university.edu',
              isLeader: true,
              isMe: true,
            ),
            const SizedBox(height: 12),
            _buildMemberCard(
              context,
              avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXgTC4DnAYNbbZqJiR2_eXQVjVBBU9UAfGrdGXOt0kuaQU0pB6NC2VA430rwd4RXjZ_hC5Hfq92mwXe2lxvfwHF5PEWKa6lPQkYXOsjQVHelRTzu19Dvk4rGSpIO4madR4j--BNrWFv3pXGHVjKPbA1Gwxzy-16impgeDJrVMZ3ur9i2TBCFnRgU_T3BSzAWjaze7feR8wzo2PmgLdiKJ29z5fHVKDnAVOwtf1F07fAyiIjCOTBsgAtrbB2A7g3j41-3bOoHBHjQM',
              name: 'Elena Morales',
              email: 'emorales@university.edu',
            ),
            const SizedBox(height: 12),
            _buildMemberCard(
              context,
              avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCrL7ehJPOSPFx9kjB2ZvERwzM3OMH8QIwIepB1EPeDn4nneI-XG4DzjJS4U4PbpYTnR-4eZt0JNAZodSqDIh8ddQ5DaGmmlhQ0oR-bgeevIdAUyjzJPhUB5ensFdryjBeIM5P_3kvP1jO2wq1hVCHPr6ZEuQzqa2_Vs_MnF2jOpDPQtSSBSbCbNl7YS_wCAsLGUTPVjepr0lY4VoAGE3GAa5EdTE-XhuxekDzHw7L5qtKjFrupUbS_x0d3pjJUISMHWC_oG_ayC_8',
              name: 'David Chen',
              email: 'dchen@university.edu',
            ),
            
            const SizedBox(height: 32),
            
            // Invitaciones Pendientes
            Row(
              children: [
                Icon(Icons.mail_outline, size: 20, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Invitaciones Pendientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'sgarcia@university.edu',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hace 2 días',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'El equipo está lleno. Cancela una invitación para invitar a alguien más.',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // AI Assistant Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerHigh.withOpacity(0.8),
                    colorScheme.surface.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: colorScheme.secondary, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Assistant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                      children: const [
                        TextSpan(text: 'Basado en los perfiles de tu equipo, tienen una '),
                        TextSpan(text: 'fuerte cobertura', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' en Backend y Frontend. Se sugiere asignar tareas de '),
                        TextSpan(text: 'documentación y pruebas unitarias', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' equitativamente para el próximo sprint.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Generar Plan de Trabajo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Salir del equipo
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text('Salir del equipo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context, {
    required String avatarUrl,
    required String name,
    required String email,
    bool isLeader = false,
    bool isMe = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? colorScheme.primary.withOpacity(0.05) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? colorScheme.primary.withOpacity(0.5) : colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              if (isLeader)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isMe)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'TÚ (LÍDER)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
