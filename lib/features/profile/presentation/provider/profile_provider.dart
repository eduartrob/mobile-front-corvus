import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobile/features/profile/data/data_source/profile_remote_data_source.dart';
import 'package:mobile/features/profile/data/models/profile_completo_model.dart';
import 'package:http/http.dart' as http;

class ProfileProvider extends ChangeNotifier {
  final ProfileRemoteDataSource remoteDataSource;
  Timer? _pollingTimer;

  ProfileProvider({ProfileRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource(client: http.Client());

  ProfileCompletoModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileCompletoModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    // Si ya estamos cargando en segundo plano por el polling, no mostramos loader pantalla completa
    if (_profile == null || forceRefresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await remoteDataSource.getPerfilCompleto(forceRefresh: forceRefresh);
      _profile = result;
      _errorMessage = null;

      // Iniciar temporizador si el backend está en proceso de cálculo asíncrono
      if (result.isProcessing) {
        _startPolling();
      } else {
        _stopPolling();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _stopPolling();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer(const Duration(seconds: 10), () {
      fetchProfile();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
