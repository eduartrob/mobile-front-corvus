import 'package:flutter/material.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/prof_profile/presentation/pages/prof_edit_profile_page.dart' as mobile;
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';

class ProfHeaderInfo extends StatefulWidget {
  final UserEntity? user;

  const ProfHeaderInfo({super.key, required this.user});

  @override
  State<ProfHeaderInfo> createState() => _ProfHeaderInfoState();
}

class _ProfHeaderInfoState extends State<ProfHeaderInfo> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = widget.user;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 18, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: (currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty)
                ? CachedNetworkImageProvider(currentUser.photoUrl!)
                : null,
            child: (currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty)
                ? const Icon(Icons.person, size: 48)
                : null,
          ),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              final profile = profileProvider.profile;
              
              final nameToShow = (profile?.alumno != null && profile!.alumno.trim().isNotEmpty && profile.alumno != profile.correo) 
                  ? profile.alumno 
                  : ((currentUser?.name != null && currentUser!.name.trim().isNotEmpty) ? currentUser!.name : 'Nombre de Profesor');
                  
              final emailToShow = (profile?.correo != null && profile!.correo!.trim().isNotEmpty)
                  ? profile.correo!
                  : ((currentUser?.email != null && currentUser!.email.trim().isNotEmpty) ? currentUser!.email : 'correo@institucional.edu');

              return Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    nameToShow,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emailToShow,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (profile != null && (profile.isVerified || profile.isGoogleLinked)) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      ] else if (profile != null && !profile.isVerified && !profile.isGoogleLinked) ...[
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 16,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: 'Verificar Correo',
                            position: PopupMenuPosition.under,
                            elevation: 3,
                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                enabled: false,
                                child: Text(
                                  'Tu correo no está verificado.',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'go_edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 12),
                                    Text('Ir a Editar Perfil para verificar'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'go_edit') {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const mobile.ProfEditProfilePage()),
                                );
                                if (context.mounted) {
                                  context.read<ProfileProvider>().fetchProfile(forceRefresh: true);
                                  context.read<AuthProvider>().checkAuthStatus();
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (profile?.correoSecundario != null && profile!.correoSecundario!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.correoSecundario!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  if (profile != null) ...[
                    const SizedBox(height: 6),
                    if (profile.universidad != null && profile.universidad!.isNotEmpty)
                      Text(
                        profile.universidad!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (profile.carrera != null && profile.carrera!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          profile.carrera!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    if (profile.habilidades.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          profile.habilidades.map((e) => e.habilidad).join(', '),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                  ],
                  Builder(
                    builder: (context) {
                      final bool isLinked = profile?.isGoogleLinked == true || 
                          (profile?.googleEmail != null && profile!.googleEmail!.isNotEmpty);
                      
                      if (profile != null && !isLinked) {
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Material(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? colorScheme.surfaceContainer 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: profileProvider.isLoading ? null : () async {
                                  try {
                                    final googleSignIn = GoogleSignIn(
                                      scopes: ['email', 'profile'],
                                      serverClientId: kIsWeb ? null : '1078483343139-2fobsjceva5r60i6vrpcg4jbjddmj4uo.apps.googleusercontent.com',
                                    );
                                    try {
                                      await googleSignIn.disconnect();
                                    } catch (_) {
                                      await googleSignIn.signOut();
                                    }
                                    final googleUser = await googleSignIn.signIn();
                                    if (googleUser == null) return;

                                    String? authCode = googleUser.serverAuthCode;
                                    if (authCode == null) {
                                      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
                                      authCode = googleAuth.idToken ?? googleAuth.accessToken;
                                    }
                                    
                                    if (authCode == null) {
                                      throw Exception('No se pudo obtener el token de Google');
                                    }
                                    
                                    await profileProvider.linkGoogleAccount(authCode);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Cuenta vinculada exitosamente'), backgroundColor: Colors.green),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error al vincular: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/google.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Vincular cuenta de Google',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (isLinked) {
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/google.svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Cuenta de Google vinculada',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}