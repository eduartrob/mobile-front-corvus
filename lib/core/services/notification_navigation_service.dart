import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';

/// Servicio dedicado para manejar la navegación al tocar una notificación.
/// Centraliza toda la lógica de routing por tipo de notificación y deepLink.
///
/// Extraído de main.dart para cumplir el principio de responsabilidad única.
class NotificationNavigationService {
  NotificationNavigationService._();

  /// Maneja el tap en una notificación cuando la app está en
  /// background o terminada.
  static void handle(RemoteMessage message) {
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
    _handleByType(context, notifType, data);
  }

  static void _handleByType(
    BuildContext context,
    String notifType,
    Map<String, dynamic> data,
  ) {
    switch (notifType) {
      case 'TEAM_INVITE':
      case 'team_invite':
      case 'team_accepted':
      case 'team_rejected':
      case 'team_updated':
        final projectId = _resolveProjectId(context, data);
        if (projectId != null) {
          context.push('/project/$projectId?tab=1');
        } else {
          context.push('/inspiration');
        }

      case 'review_updated':
        final projectId = data['projectId'] as String?;
        if (projectId != null) {
          context.push('/project/$projectId?tab=2');
        } else {
          context.push('/notifications?highlightLatest=true');
        }

      case 'security_new_device':
        context.push('/security-alert');

      case 'payment_update':
        context.push('/profile');

      default:
        context.push('/notifications?highlightLatest=true');
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
