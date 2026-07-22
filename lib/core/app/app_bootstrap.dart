import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:mobile/features/notifications/presentation/provider/notifications_provider.dart';
import 'package:mobile/features/prof_dash/presentation/provider/prof_dash_provider.dart';

/// Widget raíz que escucha cambios de autenticación y dispara la carga
/// de datos esenciales solo cuando el usuario está autenticado.
///
/// Este patrón evita cargar datos masivamente durante el arranque;
/// en cambio, todo se carga on-demand después de verificar el estado de auth.
class AppBootstrap extends StatefulWidget {
  final AuthProvider authProvider;
  final Widget child;

  const AppBootstrap({
    super.key,
    required this.authProvider,
    required this.child,
  });

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _wasAuthenticated =
        widget.authProvider.status == AuthStatus.authenticated;
    widget.authProvider.addListener(_onAuthChanged);

    // Si ya está autenticado al arrancar (sesión persistida), cargar esenciales
    if (_wasAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEssentialData());
    }
  }

  @override
  void dispose() {
    widget.authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final isAuth = widget.authProvider.status == AuthStatus.authenticated;

    if (isAuth && !_wasAuthenticated) {
      // Usuario acaba de autenticarse → cargar datos esenciales
      _wasAuthenticated = true;
      _loadEssentialData();
    } else if (!isAuth && _wasAuthenticated) {
      // Usuario acaba de cerrar sesión → limpiar estado de todos los providers
      _wasAuthenticated = false;
      _clearAllProviders();
    }
  }

  /// Limpia todos los providers para evitar fugas de estado entre sesiones.
  void _clearAllProviders() {
    if (!mounted) return;
    try { context.read<MyProjectProvider>().reset(''); } catch (_) {}
    try { context.read<TeamsProvider>().clear(); } catch (_) {}
    try { context.read<ProfileProvider>().clear(); } catch (_) {}
    try { context.read<ProjectProvider>().clear(); } catch (_) {}
    try { context.read<InspirationProvider>().clear(); } catch (_) {}
    try { context.read<NotificationsProvider>().clear(); } catch (_) {}
    try { context.read<ProfDashboardProvider>().clear(); } catch (_) {}
    FirebaseMessaging.instance.unsubscribeFromTopic('config_updates');
  }

  /// Carga solo los datos esenciales para el primer frame autenticado.
  /// El resto de features cargan bajo demanda cuando el usuario visita
  /// cada pantalla (lazy loading).
  void _loadEssentialData() {
    if (!mounted) return;
    final uid = widget.authProvider.currentUser?.id;
    if (uid == null) return;

    final teamsProvider = context.read<TeamsProvider>();
    final myProjectProvider = context.read<MyProjectProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final notificationsProvider = context.read<NotificationsProvider>();

    // Teams es necesario para saber si el alumno ya tiene equipo
    teamsProvider.fetchMyTeam().then((_) {
      if (!mounted) return;
      final teamId = teamsProvider.myTeam?.id ?? '';
      myProjectProvider.init(uid, teamId);
    });

    profileProvider.fetchProfile();
    notificationsProvider.fetchNotifications(silent: true);

    // Cargar proyectos silenciosamente
    final projectProvider = context.read<ProjectProvider>();
    final token = widget.authProvider.currentUser?.token;
    if (token != null) {
      projectProvider.loadMyProjects(token, quiet: true, userId: uid);
    }

    // Namespacear SharedPreferences por usuario
    context.read<InspirationProvider>().setUserId(uid);

    // Suscribir a FCM topics según el rol
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
