import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/prof_rules/presentation/provider/prof_rules_provider.dart';
import '../../features/notifications/presentation/provider/notifications_provider.dart';
import '../../features/teams/presentation/provider/teams_provider.dart';

class PushSyncService {
  static final PushSyncService _instance = PushSyncService._internal();
  factory PushSyncService() => _instance;
  PushSyncService._internal();

  /// Inicializa la sincronización por push silenciosos y solicita permisos de FCM
  Future<void> initialize(BuildContext context) async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Escuchar mensajes en primer plano (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleMessage(context, message);
      });

      // Escuchar mensajes al abrir la app desde segundo plano
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessage(context, message);
      });
    } catch (e) {
      debugPrint('Error inicializando PushSyncService: $e');
    }
  }

  void _handleMessage(BuildContext context, RemoteMessage message) {
    try {
      final data = message.data;
      context.read<NotificationsProvider>().fetchNotifications(silent: true);

      if (data['type'] == 'CONFIG_UPDATED') {
        _triggerSilentReload(context);
      } else if (data['type'] == 'team_request' || data['type'] == 'team_accept' || data['type'] == 'team_update' || data.containsKey('teamId')) {
        context.read<TeamsProvider>().fetchMyTeam();
        context.read<TeamsProvider>().fetchRequests();
      } else {
        // Por defecto, refrescar la vista del equipo ante cualquier notificación de equipo
        context.read<TeamsProvider>().fetchMyTeam();
      }
    } catch (e) {
      debugPrint('Error en recarga por push: $e');
    }
  }

  void _triggerSilentReload(BuildContext context) {
    try {
      context.read<ProfRulesProvider>().fetchData();
      context.read<TeamsProvider>().fetchMyTeam();
      debugPrint('🔄 Push Silencioso: Caché invalidado y datos recargados.');
    } catch (e) {
      debugPrint('Error en _triggerSilentReload: $e');
    }
  }
}
