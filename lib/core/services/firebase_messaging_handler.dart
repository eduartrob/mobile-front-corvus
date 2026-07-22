import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/features/notifications/data/notifications_local_data_source.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/notifications/presentation/provider/notifications_provider.dart';
import 'package:mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:go_router/go_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await handleFCMMessage(message);
  } catch (e) {}
}

/// Extrae la ruta actual del router para logica WhatsApp-like
String? _getCurrentRoute() {
  try {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return null;
    return GoRouterState.of(context).matchedLocation;
  } catch (_) {
    return null;
  }
}

/// Navega al deep-link dado si hay contexto disponible
void _navigateToDeepLink(String? deepLink) {
  if (deepLink == null || deepLink.isEmpty) return;
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;
  try {
    context.go(deepLink);
  } catch (e) {
    debugPrint('Error navegando a deepLink $deepLink: $e');
  }
}

Future<void> handleFCMMessage(RemoteMessage message) async {
  final data = message.data;
  final notifType = data['type'] ?? '';
  final deepLink = data['deepLink'] as String?;

  final storage = SecureStorageService();
  final role = await storage.read(key: 'auth_role');

  if (message.notification != null) {
    // Guardar en SQLite
    await NotificationsLocalDataSource.insertNotification({
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'title': message.notification!.title ?? 'Nueva Notificacion',
      'body': message.notification!.body ?? '',
      'type': notifType,
      'deepLink': deepLink,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': 0,
      'authorName': data['authorName'],
      'authorPhotoUrl': data['authorPhotoUrl'],
    });

    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      try {
        context.read<NotificationsProvider>().fetchNotifications(silent: true);

        // Reactividad: actualizar providers segun tipo
        if (notifType == 'team_request' || notifType == 'team_accept' ||
            notifType == 'team_invite' || notifType == 'team_accepted' ||
            notifType == 'team_rejected' || notifType == 'team_updated') {
          context.read<TeamsProvider>().fetchMyTeam();
          context.read<TeamsProvider>().fetchRequests();
          context.read<TeamsProvider>().fetchSuggestions();
        }

        if (notifType == 'CONFIG_UPDATED' || notifType == 'project_updated') {
          context.read<TeamsProvider>().fetchMyTeam();
          context.read<MyProjectProvider>().refreshConfig();
        }
      } catch (e) {
        debugPrint('Provider no disponible en context: $e');
      }
    }

    // -- Logica WhatsApp-like: suprimir si estamos en la pantalla correcta --
    bool skipHeadsUp = false;
    final currentRoute = _getCurrentRoute();

    // Si estamos en /notifications suprimir siempre
    if (NotificationsPage.isOpen) skipHeadsUp = true;

    // Suprimir config updates para profesores
    if (notifType == 'CONFIG_UPDATED' && role == 'PROFESOR') skipHeadsUp = true;

    // Si el deepLink coincide con la ruta actual, suprimir heads-up
    if (deepLink != null && currentRoute != null) {
      final deepLinkBase = deepLink.split('?').first;
      final currentBase = currentRoute.split('?').first;
      if (deepLinkBase == currentBase) skipHeadsUp = true;
    }

    if (!skipHeadsUp) {
      NotificationService().showResultNotification(
        message.notification!.title ?? 'Nueva Notificacion',
        message.notification!.body ?? '',
        payload: deepLink ?? notifType,
      );
    } else {
      debugPrint('Alerta visual suprimida: estas en la pantalla relevante.');
    }
  }

  // -- Handlers especiales por tipo --

  if (notifType == 'sync_progress') {
    final progress = int.tryParse(data['progress']?.toString() ?? '0') ?? 0;
    final total = int.tryParse(data['total']?.toString() ?? '100') ?? 100;
    final msg = data['message'] ?? 'Procesando...';
    NotificationService().showProgressNotification(
      progress: progress,
      maxProgress: total,
      title: 'Sincronizacion de Archivos',
      message: msg
    );
  } else if (notifType == 'sync_complete') {
    NotificationService().showSuccessNotification(
      title: 'Sincronizacion Completada!',
      message: data['message'] ?? 'Los archivos fueron vectorizados correctamente.'
    );
  } else if (notifType == 'CONFIG_UPDATED') {
    try {
      final allData = await storage.readAll();
      final keysToDelete = allData.keys.where((key) =>
        key.startsWith('cached_prof_config') ||
        key.startsWith('etag_prof_config') ||
        key.startsWith('cached_cluster_stats') ||
        key.startsWith('etag_cluster_stats')
      ).toList();
      for (final key in keysToDelete) {
        await storage.delete(key: key);
      }
    } catch (e) {
      // Ignorar error
    }
  } else if (notifType == 'security_new_device') {
    // Navegar a la pantalla interactiva de seguridad
    _navigateToDeepLink('/security-alert');
  }
}
