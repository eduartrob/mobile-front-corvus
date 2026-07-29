import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/providers/auth_provider.dart';
import 'package:mobile/core/services/secure_storage_service.dart';

/// Servicio dedicado para manejar la navegación al tocar una notificación.
/// Centraliza toda la lógica de routing por tipo de notificación y deepLink.
///
/// Extraído de main.dart para cumplir el principio de responsabilidad única.
class NotificationNavigationService {
  NotificationNavigationService._();

  /// Maneja el tap en una notificación cuando la app está en
  /// background o terminada.
  static Future<void> handle(RemoteMessage message) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final data = message.data;
    final deepLink = data['deepLink'] as String?;
    final notifType = data['type'] ?? '';

    // 1. Priorizar deepLink si viene del backend
    if (deepLink != null && deepLink.isNotEmpty) {
      try {
        context.go(deepLink);
        return;
      } catch (e) {
        debugPrint('NotificationNavigation: Error navegando a deepLink "$deepLink": $e');
      }
    }

    // 2. Fallback por tipo de notificación
    await handleByType(context, notifType, data);
  }

  static Future<void> handleByType(
    BuildContext context,
    String notifType,
    Map<String, dynamic> data,
  ) async {
    switch (notifType) {
      case 'CLASSROOM_UPDATE':
      case 'PROJECT_UPDATE':
      case 'CONFIG_UPDATED':
        final projectId = _resolveProjectId(context, data);
        if (projectId != null && projectId.isNotEmpty) {
          // Check role to route correctly using secure storage
          final storage = SecureStorageService();
          final role = await storage.read(key: 'auth_role');
          if (role == 'PROFESOR' || role == 'DOCENTE') {
            context.push('/prof-project/$projectId');
          } else {
            context.push('/project/$projectId');
          }
        } else {
          _safePushNotifications(context, highlightLatest: true);
        }
        break;

      case 'TEAM_INVITE':
      case 'team_invite':
      case 'TEAM_UPDATE':
      case 'team_accepted':
      case 'team_rejected':
      case 'team_updated':
        final projectId = _resolveProjectId(context, data);
        if (projectId != null && projectId.isNotEmpty) {
          context.push('/project/$projectId?tab=0&teamTab=1');
        } else {
          _safePushNotifications(context, highlightLatest: true);
        }
        break;

      case 'PROPOSAL_ACTION':
      case 'review_updated':
        final projectId = _resolveProjectId(context, data);
        if (projectId != null && projectId.isNotEmpty) {
          context.push('/project/$projectId?tab=1'); // Tab 1 is Propuesta
        } else {
          _safePushNotifications(context, highlightLatest: true);
        }
        break;

      case 'SECURITY_DEVICE':
      case 'security_new_device':
        // Ideally this would go to a specific security settings page, assuming /profile for now
        // if /security-alert doesn't exist. We will use /profile as a safe fallback.
        context.push('/profile');
        break;

      case 'SUBSCRIPTION_CHANGE':
      case 'payment_update':
        context.push('/profile'); // User's billing settings usually in profile
        break;

      default:
        _safePushNotifications(context, highlightLatest: true);
    }
  }

  static void _safePushNotifications(BuildContext context, {bool highlightLatest = false}) {
    // Only push if we are NOT already on the notifications page
    final location = GoRouterState.of(context).matchedLocation;
    if (location != '/notifications') {
      context.push('/notifications?highlightLatest=$highlightLatest');
    }
  }

  static String? _resolveProjectId(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    if (data['projectId'] != null) return data['projectId'] as String;
    try {
      final myProjects = context.read<ProjectProvider>().myProjects;
      if (myProjects.isNotEmpty) return myProjects.first['id'] as String?;
    } catch (_) {}
    return null;
  }
}
