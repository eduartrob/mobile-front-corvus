import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_in_with_google_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/request_drive_scope_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/get_drive_access_token_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/request_classroom_scopes_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_out_from_google_usecase.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/student_directory/data/data_source/clustering_remote_data_source.dart';
<<<<<<< Updated upstream
=======
import 'dart:convert';
import 'package:mobile/core/network/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/features/auth/domain/use_cases/login_with_email_usecase.dart';
>>>>>>> Stashed changes

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final RequestDriveScopeUseCase requestDriveScopeUseCase;
  final RequestClassroomScopesUseCase requestClassroomScopesUseCase;
  final GetDriveAccessTokenUseCase getDriveAccessTokenUseCase;
  final SignOutFromGoogleUseCase signOutFromGoogleUseCase;
  final SecureStorageService _storage;

  AuthProvider({
    required this.signInWithGoogleUseCase,
    required this.requestDriveScopeUseCase,
    required this.requestClassroomScopesUseCase,
    required this.getDriveAccessTokenUseCase,
    required this.signOutFromGoogleUseCase,
    SecureStorageService? storage,
  }) : _storage = storage ?? SecureStorageService();

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _cachedRole;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get role => _currentUser?.role ?? _cachedRole;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      final savedRole = await _storage.read(key: 'auth_role');
      
      if (token != null) {
        _cachedRole = savedRole;
        
        final savedId = await _storage.read(key: 'auth_id') ?? '';
        final savedEmail = await _storage.read(key: 'auth_email') ?? '';
        final savedName = await _storage.read(key: 'auth_name') ?? '';
        final savedPhotoUrl = await _storage.read(key: 'auth_photo');

        _currentUser = UserEntity(
          id: savedId,
          email: savedEmail,
          name: savedName,
          photoUrl: savedPhotoUrl,
          token: token,
          role: savedRole,
        );

        _status = AuthStatus.authenticated;
<<<<<<< Updated upstream
=======
        
        // Fetch /me to update profile info silently in background
        apiClient.get(Uri.parse('${ApiConfig.apiGatewayUrl}/auth/me')).then((response) {
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final userData = data['user'];
            if (userData != null) {
              final updatedPhotoUrl = userData['photoUrl'];
              final updatedName = userData['name'];
              
              _currentUser = _currentUser!.copyWith(
                photoUrl: updatedPhotoUrl,
                name: updatedName,
              );
              
              if (updatedPhotoUrl != null) {
                _storage.write(key: 'auth_photo', value: updatedPhotoUrl);
              }
              if (updatedName != null) {
                _storage.write(key: 'auth_name', value: updatedName);
              }
              notifyListeners();
            }
          }
        }).catchError((_) {});

        // Registrar FCM token silenciosamente
        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null && _currentUser != null && _currentUser!.id.isNotEmpty) {
            final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/device');
            http.post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${_currentUser!.token}',
              },
              body: jsonEncode({
                'userId': _currentUser!.id,
                'fcmToken': fcmToken
              })
            ).then((r) => print('FCM guardado al restaurar sesión: ${r.statusCode}'))
            .catchError((e) => print('Error FCM rest: $e'));
          }
        } catch(e) {
          print('Error FCM al restaurar sesión: $e');
        }

>>>>>>> Stashed changes
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await signInWithGoogleUseCase();
      _currentUser = user;
      _cachedRole = user.role;
      
      if (user.token != null) {
        await _storage.write(key: 'auth_token', value: user.token!);
      }
      if (user.role != null) {
        await _storage.write(key: 'auth_role', value: user.role!);
      }
      await _storage.write(key: 'auth_id', value: user.id);
      await _storage.write(key: 'auth_email', value: user.email);
      await _storage.write(key: 'auth_name', value: user.name);
      if (user.photoUrl != null) {
        await _storage.write(key: 'auth_photo', value: user.photoUrl!);
      }

      await NotificationService().requestPermission();

      try {
        // Trigger profile parsing in background silently
        final clusteringDs = ClusteringRemoteDataSource(client: apiClient);
        clusteringDs.syncStudentProfile().catchError((_) => <String, dynamic>{});
      } catch (_) {}

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ ERROR CRÍTICO EN signInWithGoogle (AuthProvider):');
      print('Excepción: $e');
      print('Stack Trace:\n$stackTrace');
      String errorStr = e.toString();
      if (errorStr.contains('USER_NOT_REGISTERED|')) {
        _errorMessage = errorStr.replaceAll('Exception: ', '');
      } else if (errorStr.contains('403') || errorStr.toLowerCase().contains('upchiapas') || errorStr.toLowerCase().contains('domain') || errorStr.toLowerCase().contains('permitido')) {
        _errorMessage = 'AUTH_NOT_ALLOWED';
      } else if (errorStr.toLowerCase().contains('canceled') || errorStr.toLowerCase().contains('cancelado')) {
        _errorMessage = 'AUTH_CANCELED';
      } else {
        _errorMessage = errorStr.replaceAll('Exception: ', '');
      }
      
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  Future<bool> requestDriveAccess() async {
    try {
      return await requestDriveScopeUseCase();
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestClassroomScopes() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return false;
      return await requestClassroomScopesUseCase(token);
    } catch (e) {
      return false;
    }
  }

  Future<String?> getDriveAccessToken() async {
    try {
      return await getDriveAccessTokenUseCase();
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/device');
        await http.delete(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (_currentUser?.token != null) 'Authorization': 'Bearer ${_currentUser!.token}',
          },
          body: jsonEncode({'fcmToken': fcmToken})
        );
      }
    } catch (e) {
      print('Error al desregistrar FCM: $e');
    }

    try {
      await signOutFromGoogleUseCase();
    } catch (e) {
    }

    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'auth_role');
    await _storage.delete(key: 'auth_id');
    await _storage.delete(key: 'auth_email');
    await _storage.delete(key: 'auth_name');
    await _storage.delete(key: 'auth_photo');
    _currentUser = null;
    _cachedRole = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
