import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SecurityService {
  static const MethodChannel _channel = MethodChannel('app.security.channel');

  Future<void> preventScreenshots(bool prevent) async {
    // Desactivado temporalmente para facilitar pruebas y capturas de pantalla.
    // Para reactivar, descomentar el bloque de abajo.
    /*
    if (kIsWeb) return;

    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('preventScreenshots', {'prevent': prevent});
      } catch (e) {
        debugPrint("Error configuring screen protection: '${e.toString()}'.");
      }
    }
    */
  }

  Future<bool> isUsbDebuggingEnabled() async {
    if (kIsWeb) return false;
    
    if (Platform.isAndroid) {
      try {
        final bool isEnabled = await _channel.invokeMethod('isUsbDebuggingEnabled');
        return isEnabled;
      } catch (e) {
        debugPrint("Error checking USB Debugging: '${e.toString()}'.");
      }
    }
    return false;
  }
}
