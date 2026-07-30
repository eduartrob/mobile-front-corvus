import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SecurityService {
  static const MethodChannel _channel = MethodChannel('app.security.channel');

  Future<void> preventScreenshots(bool prevent) async {
    // desactivado temporalmente para facilitar pruebas y capturas de pantalla 
    // para reactivar descomentar el bloque de abajo 
    if (kIsWeb) return;

    // if platform isandroid 
    // try 
    // await channel invokemethod preventscreenshots prevent prevent 
    // catch e 
    // debugprint error configuring screen protection e tostring 
    // 
    // 
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
