import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/profile/presentation/pages/edit_profile_page.dart' as mobile;
import 'package:mobile/features/profile/presentation/pages/pro_plan_page.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile/shared/widgets/pro_avatar.dart';

class StudentHeaderInfo extends StatefulWidget {
  final UserEntity? user;

  const StudentHeaderInfo({super.key, required this.user});

  @override
  State<StudentHeaderInfo> createState() => _StudentHeaderInfoState();
}

class _StudentHeaderInfoState extends State<StudentHeaderInfo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().fetchProSubscriptionStatus().catchError((_) {});
      }
    });
  }

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
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ProAvatar(
                photoUrl: currentUser?.photoUrl,
                radius: 48,
                isPro: authProvider.isProActive,
                fallbackInitial: currentUser?.name ?? 'U',
              );
            },
          ),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              final profile = profileProvider.profile;
              
              final nameToShow = (profile?.alumno != null && profile!.alumno.trim().isNotEmpty && profile.alumno != profile.correo) 
                  ? profile.alumno 
                  : (currentUser?.name.trim().isNotEmpty == true ? currentUser!.name : 'Nombre de Alumno');
                  
              final emailToShow = (profile?.correo != null && profile!.correo!.trim().isNotEmpty)
                  ? profile.correo!
                  : (currentUser?.email.trim().isNotEmpty == true ? currentUser!.email : 'correo@institucional.edu');

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
                                  MaterialPageRoute(builder: (context) => const mobile.EditProfilePage()),
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
                      if (profile.cuatrimestre != null && profile.cuatrimestre!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Cuatrimestre: ${profile.cuatrimestre}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final isPro = authProvider.isProActive;
                        final expiresAtRaw = authProvider.proExpiresAt;
                        
                        DateTime? expiresDate;
                        if (expiresAtRaw != null) {
                          expiresDate = DateTime.tryParse(expiresAtRaw);
                        }
                        
                        int daysLeft = 0;
                        if (expiresDate != null) {
                          daysLeft = expiresDate.difference(DateTime.now()).inDays;
                          if (daysLeft < 0) daysLeft = 0;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient: isPro
                                      ? const LinearGradient(
                                          colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isPro ? null : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: isPro
                                      ? [
                                          BoxShadow(
                                            color: Colors.amber.withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isPro)
                                      Lottie.asset(
                                        'assets/animations/Premium Gold.json',
                                        width: 22,
                                        height: 22,
                                        fit: BoxFit.contain,
                                      )
                                    else
                                      Icon(
                                        Icons.shield_outlined,
                                        size: 17,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isPro ? 'MEMBRESÍA PRO' : 'PLAN GRATUITO',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isPro ? Colors.black : colorScheme.onSurfaceVariant,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    if (isPro) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time_rounded, size: 12, color: Colors.black),
                                            const SizedBox(width: 4),
                                            Text(
                                              daysLeft > 0 ? '$daysLeft días' : 'Vence hoy',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
                  const ProPromoBannerWidget(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProPromoBannerWidget extends StatefulWidget {
  const ProPromoBannerWidget({super.key});

  @override
  State<ProPromoBannerWidget> createState() => _ProPromoBannerWidgetState();
}

class _ProPromoBannerWidgetState extends State<ProPromoBannerWidget> with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _swapController;
  Timer? _timer;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _promoCards = [
    {
      'title': '¡Cámbiate al Plan PRO! 🚀',
      'subtitle': 'Desbloquea el Simulador por Voz Gemini Live y validaciones ilimitadas.',
      'gradient': const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
      'glowColor': const Color(0xFF6366F1),
    },
    {
      'title': '¿Entrenando para tu Defensa? 🎙️',
      'subtitle': 'Practica respuestas por voz en tiempo real con IA e impresiona al jurado.',
      'gradient': const [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
      'glowColor': const Color(0xFF10B981),
    },
    {
      'title': 'Obtén tu Insignia VIP Dorada 👑',
      'subtitle': 'Destaca entre los proyectos de tu facultad y accede a matchmaking exclusivo.',
      'gradient': const [Color(0xFF3B0764), Color(0xFF6B21A8), Color(0xFF7E22CE)],
      'glowColor': const Color(0xFFA855F7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && !_swapController.isAnimating) {
        _swapController.forward(from: 0.0).then((_) {
          if (mounted) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % _promoCards.length;
              _swapController.reset();
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _swapController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isProActive) return const SizedBox.shrink();

        final nextIndex = (_currentIndex + 1) % _promoCards.length;

        return Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: SizedBox(
            height: 84,
            child: AnimatedBuilder(
              animation: Listenable.merge([_shimmerController, _swapController]),
              builder: (context, child) {
                final double swapVal = CurvedAnimation(
                  parent: _swapController,
                  curve: Curves.easeInOutCubic,
                ).value;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // --- 1. TARJETA TRASERA (Asoma sutilmente en el mazo) ---
                    Transform.translate(
                      offset: Offset(0, -6 * (1.0 - swapVal)),
                      child: Transform.scale(
                        scale: 0.94 + (0.06 * swapVal),
                        child: Opacity(
                          opacity: 0.55 + (0.45 * swapVal),
                          child: _buildSingleCard(_promoCards[nextIndex], isFront: false),
                        ),
                      ),
                    ),

                    // --- 2. TARJETA FRONTAL (Se desliza hacia abajo intercambiándose) ---
                    if (swapVal < 1.0)
                      Transform.translate(
                        offset: Offset(0, 35 * swapVal),
                        child: Transform.scale(
                          scale: 1.0 - (0.06 * swapVal),
                          child: Opacity(
                            opacity: (1.0 - (swapVal * 1.2)).clamp(0.0, 1.0),
                            child: _buildSingleCard(_promoCards[_currentIndex], isFront: true),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleCard(Map<String, dynamic> cardData, {required bool isFront}) {
    final List<Color> cardGradient = cardData['gradient'] as List<Color>;
    final Color glowColor = cardData['glowColor'] as Color;
    final double sweepOffset = -2.5 + (_shimmerController.value * 5.0);

    return Container(
      width: double.infinity,
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            cardGradient[0],
            cardGradient[1],
            isFront ? const Color(0xFFFFFFFF).withValues(alpha: 0.35) : cardGradient[1],
            cardGradient[1],
            cardGradient[2],
          ],
          stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
          begin: Alignment(sweepOffset, -1.0),
          end: Alignment(sweepOffset + 1.2, 1.0),
        ),
        boxShadow: isFront
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProPlanPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Lottie.asset(
                  'assets/animations/Premium Gold.json',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cardData['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cardData['subtitle'] as String,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}