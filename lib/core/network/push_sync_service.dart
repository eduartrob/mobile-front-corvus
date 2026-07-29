import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/prof_rules/presentation/provider/prof_rules_provider.dart';
import '../../features/my_project/presentation/provider/my_project_provider.dart';

class PushSyncService {
  static final PushSyncService _instance = PushSyncService._internal();
  factory PushSyncService() => _instance;
  PushSyncService._internal();

  /// inicializa la sincronización por push silenciosos
  Future<void> initialize(BuildContext context) async {
    final messaging = FirebaseMessaging.instance;

    // solicitar permisos en caso de ios
    await messaging.requestPermission();

    // se quita la suscripción global ahora se suscribe solo si el usuario es alumno en main dart
    
    // escuchar mensajes en primer plano foreground 
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'CONFIG_UPDATED') {
        _triggerSilentReload(context);
      }
    });

    // escuchar mensajes al abrir la app desde segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'CONFIG_UPDATED') {
        _triggerSilentReload(context);
      }
    });
  }

  void _triggerSilentReload(BuildContext context) {
    // llamar a los providers para forzar una recarga
    // si la vista está activa se actualizará instantáneamente 
    try {
      context.read<ProfRulesProvider>().fetchData();
      // context read myprojectprovider loaduserandproject revisar nombre del metodo
      debugPrint('🔄 Push Silencioso: Caché invalidado y datos recargados.');
    } catch (e) {
      debugPrint('Error en recarga por push: $e');
    }
  }
}
