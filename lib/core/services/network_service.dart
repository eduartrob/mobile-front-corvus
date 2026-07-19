import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Track if we are currently offline to avoid spamming
  bool _isOffline = false;

  void initialize(GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // connectivity_plus 7.x returns a List<ConnectivityResult>
      bool isConnected = results.any((result) => result != ConnectivityResult.none);

      if (!isConnected && !_isOffline) {
        _isOffline = true;
        _showOfflineSnackBar(scaffoldMessengerKey);
      } else if (isConnected && _isOffline) {
        _isOffline = false;
        _showOnlineSnackBar(scaffoldMessengerKey);
      }
    });
  }

  void _showOfflineSnackBar(GlobalKey<ScaffoldMessengerState> key) {
    key.currentState?.hideCurrentSnackBar();
    key.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Sin conexión a Internet. Verifica tu red.')),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 365), // Keeps it visible until network returns
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showOnlineSnackBar(GlobalKey<ScaffoldMessengerState> key) {
    key.currentState?.hideCurrentSnackBar();
    key.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Conexión restaurada')),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
