import 'package:flutter/foundation.dart';
import 'package:mobile/features/profile/data/data_source/profile_remote_data_source.dart';
import 'package:mobile/features/profile/data/models/profile_completo_model.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/error/error_handler.dart';
import 'package:mobile/core/error/app_exception.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileProvider({ProfileRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource(client: sl<AuthInterceptorClient>());

  ProfileCompletoModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileCompletoModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clear() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    if (_profile == null) {
      _profile = await remoteDataSource.getCachedProfile();
      if (_profile != null) {
        notifyListeners(); // Update UI instantly with cached data
      }
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProfile = await remoteDataSource.getPerfilCompleto(forceRefresh: forceRefresh);

      if (newProfile.isProcessing && _profile != null) {
        // Retain old fields but set isProcessing to true
        _profile = ProfileCompletoModel(
          alumno: _profile!.alumno,
          correo: _profile!.correo,
          correoSecundario: _profile!.correoSecundario,
          isGoogleLinked: _profile!.isGoogleLinked,
          universidad: _profile!.universidad,
          carrera: _profile!.carrera,
          cuatrimestre: _profile!.cuatrimestre,
          matricula: _profile!.matricula,
          isVerified: _profile!.isVerified,
          secondaryIsVerified: _profile!.secondaryIsVerified,
          googleEmail: _profile!.googleEmail,
          resumen: _profile!.resumen,
          documentosConIa: _profile!.documentosConIa,
          materias: _profile!.materias,
          habilidades: _profile!.habilidades,
          isProcessing: true,
          progress: newProfile.progress,
          message: newProfile.message,
        );
        _isLoading = false;
        notifyListeners();
        _pollProfile();
      } else if (newProfile.isProcessing && _profile == null) {
        _profile = newProfile;
        _isLoading = false;
        notifyListeners();
        _pollProfile();
      } else {
        _profile = newProfile;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      _isLoading = false;
      notifyListeners();
    }
  }

  void _pollProfile() async {
    while (_profile != null && _profile!.isProcessing) {
      await Future.delayed(const Duration(seconds: 5));
      try {
        final newProfile = await remoteDataSource.getPerfilCompleto(forceRefresh: false);
        _profile = newProfile;

        if (!_profile!.isProcessing) {
          notifyListeners();
          break;
        }
      } catch (e, st) {
        _errorMessage = mapErrorToMessage(e, stackTrace: st);
        notifyListeners();
        break;
      }
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String enrollmentId,
    required String semester,
    required List<String> skills,
    List<String>? careers,
  }) async {
    // Optimistic Update: Actualizar la UI inmediatamente antes de ir al servidor
    if (_profile != null) {
      _profile = ProfileCompletoModel(
        alumno: fullName.isNotEmpty ? fullName : _profile!.alumno,
        correo: _profile!.correo,
        correoSecundario: _profile!.correoSecundario,
        isGoogleLinked: _profile!.isGoogleLinked,
        universidad: _profile!.universidad,
        carrera: (careers != null && careers.isNotEmpty) ? careers.first : _profile!.carrera,
        cuatrimestre: semester.isNotEmpty ? semester : _profile!.cuatrimestre,
        matricula: enrollmentId.isNotEmpty ? enrollmentId : _profile!.matricula,
        isVerified: _profile!.isVerified,
        secondaryIsVerified: _profile!.secondaryIsVerified,
        googleEmail: _profile!.googleEmail,
        resumen: _profile!.resumen,
        documentosConIa: _profile!.documentosConIa,
        materias: _profile!.materias,
        habilidades: skills.map((s) => HabilidadModel(habilidad: s, nivel: 'Intermedio', porcentaje: 100, materias: [])).toList(),
        isProcessing: _profile!.isProcessing,
        progress: _profile!.progress,
        message: _profile!.message,
      );
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.updateProfile(
        fullName: fullName,
        enrollmentId: enrollmentId,
        semester: semester,
        skills: skills,
        careers: careers,
      );
      // Tras guardar, traemos los datos reales por si algo más cambió
      await fetchProfile(forceRefresh: true);
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<void> requestVerificationCode(String type) async {
    try {
      await remoteDataSource.requestVerificationCode(type);
    } catch (e, st) {
      final msg = mapErrorToMessage(e, stackTrace: st);
      throw ValidationException(msg);
    }
  }

  Future<void> confirmVerificationCode(String code, String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.confirmVerificationCode(code, type);
      await fetchProfile(forceRefresh: true);
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> linkGoogleAccount(String authCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.linkGoogleAccount(authCode);
      await fetchProfile(forceRefresh: true);
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addSecondaryEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.addSecondaryEmail(email);
      await fetchProfile(forceRefresh: true);
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEmail(String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.deleteEmail(type);
      await fetchProfile(forceRefresh: true);
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
