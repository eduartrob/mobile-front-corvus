import 'package:mobile/core/network/api_endpoints.dart';
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
import 'dart:convert';
import 'package:mobile/core/network/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/features/auth/domain/use_cases/login_with_email_usecase.dart';
import 'package:mobile/core/error/error_handler.dart';
import 'package:mobile/core/error/app_exception.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class PaymentCreationResult {
  final String id;
  final String urlPago;

  PaymentCreationResult({required this.id, required this.urlPago});

  factory PaymentCreationResult.fromJson(Map<String, dynamic> json) {
    return PaymentCreationResult(
      id: json['id']?.toString() ?? '',
      urlPago: json['url_pago']?.toString() ?? json['urlPago']?.toString() ?? '',
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final RequestDriveScopeUseCase requestDriveScopeUseCase;
  final RequestClassroomScopesUseCase requestClassroomScopesUseCase;
  final GetDriveAccessTokenUseCase getDriveAccessTokenUseCase;
  final SignOutFromGoogleUseCase signOutFromGoogleUseCase;
  final SecureStorageService _storage;

  AuthProvider({
    required this.signInWithGoogleUseCase,
    required this.loginWithEmailUseCase,
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

  bool _isProActive = false;
  String? _proPlan;
  String? _proExpiresAt;
  bool get isProActive => _isProActive;
  String? get proPlan => _proPlan;
  String? get proExpiresAt => _proExpiresAt;

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
        final savedProActive = await _storage.read(key: 'auth_pro_active');
        _isProActive = (savedProActive == 'true');

        _status = AuthStatus.authenticated;
        fetchProSubscriptionStatus(email: savedEmail).catchError((_) {});
        
        // Fetch /me to update profile info silently in background
        sl<AuthInterceptorClient>().get(Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authMe}')).then((response) {
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final userData = data['user'];
            if (userData != null) {
              final updatedPhotoUrl = userData['photoUrl'];
              final updatedName = userData['name'];
              final updatedUniversityId = userData['universityId'] as String?;
              final updatedCareerId = userData['careerId'] as String?;
              
              _currentUser = _currentUser!.copyWith(
                photoUrl: updatedPhotoUrl,
                name: updatedName,
                universityId: updatedUniversityId,
                careerId: updatedCareerId,
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
            FirebaseMessaging.instance.subscribeToTopic('user_${_currentUser!.id}');
            final uri = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.notificationsDevice}');
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
            ).catchError((e) => null);
          }
        } catch(e) {
          // FCM restore failed silently
        }

      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e, st) {
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
        final clusteringDs = ClusteringRemoteDataSource(client: sl<AuthInterceptorClient>());
        clusteringDs.syncStudentProfile().catchError((_) => <String, dynamic>{});
      } catch (_) {}

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e, st) {
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

  Future<void> loginWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await loginWithEmailUseCase(email, password);
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
        final clusteringDs = ClusteringRemoteDataSource(client: sl<AuthInterceptorClient>());
        clusteringDs.syncStudentProfile().catchError((_) => <String, dynamic>{});
      } catch (_) {}

      _status = AuthStatus.authenticated;
      fetchProSubscriptionStatus(email: user.email).catchError((_) {});
      notifyListeners();
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  Future<bool> requestDriveAccess() async {
    try {
      return await requestDriveScopeUseCase();
    } catch (e, st) {
      return false;
    }
  }

  Future<bool> requestClassroomScopes() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return false;
      return await requestClassroomScopesUseCase(token);
    } catch (e, st) {
      return false;
    }
  }

  Future<String?> getDriveAccessToken() async {
    try {
      return await getDriveAccessTokenUseCase();
    } catch (e, st) {
      return null;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 3));
      if (fcmToken != null) {
        final uri = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.notificationsDevice}');
        await http.delete(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (_currentUser?.token != null) 'Authorization': 'Bearer ${_currentUser!.token}',
          },
          body: jsonEncode({'fcmToken': fcmToken})
        ).timeout(const Duration(seconds: 3));
      }
      if (_currentUser != null) {
        await FirebaseMessaging.instance.unsubscribeFromTopic('user_${_currentUser!.id}').timeout(const Duration(seconds: 3));
      }
    } catch (e, st) {
      // FCM deregister failed silently
    }

    try {
      await signOutFromGoogleUseCase().timeout(const Duration(seconds: 3));
    } catch (e, st) {
    }

    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'auth_role');
    await _storage.delete(key: 'auth_id');
    await _storage.delete(key: 'auth_email');
    await _storage.delete(key: 'registered_with_google');
    await _storage.delete(key: 'auth_name');
    await _storage.delete(key: 'auth_photo');
    _currentUser = null;
    _cachedRole = null;
    _isProActive = false;
    _proPlan = null;
    _proExpiresAt = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> fetchProSubscriptionStatus({String? email}) async {
    final currentEmail = email ?? _currentUser?.email ?? await _storage.read(key: 'auth_email');
    if (currentEmail == null || currentEmail.isEmpty) return;
    try {
      final token = await _storage.read(key: 'auth_token');
      final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/pagos/suscripcion/' + Uri.encodeComponent(currentEmail));
      final response = await sl<AuthInterceptorClient>().get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _isProActive = data['activa'] == true || data['activa']?.toString().toLowerCase() == 'true';
        _proPlan = data['plan']?.toString();
        _proExpiresAt = data['vence']?.toString();
        await _storage.write(key: 'auth_pro_active', value: _isProActive ? 'true' : 'false');
      } else {
        _isProActive = false;
        _proPlan = null;
        _proExpiresAt = null;
        await _storage.write(key: 'auth_pro_active', value: 'false');
      }
    } catch (_) {
      _isProActive = false;
      _proPlan = null;
      _proExpiresAt = null;
    }
    notifyListeners();
  }

  Future<PaymentCreationResult> createPayment({required String metodo}) async {
    final email = _currentUser?.email ?? await _storage.read(key: 'auth_email');
    if (email == null || email.isEmpty) {
      throw Exception('No se encontró el email del usuario');
    }
    final token = await _storage.read(key: 'auth_token');
    final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/pagos/crear');
    final body = jsonEncode({
      'alumno_email': email,
      'concepto': 'Plan Pro mensual',
      'monto': 50.00,
      'metodo': metodo,
    });
    final response = await sl<AuthInterceptorClient>().post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final result = PaymentCreationResult.fromJson(data);
      if (result.id.isEmpty || result.urlPago.isEmpty) {
        throw Exception('Respuesta inválida del servicio de pagos');
      }
      return result;
    }
    throw Exception('Error al crear pago: ' + response.statusCode.toString());
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    if (paymentId.isEmpty) throw Exception('ID de pago inválido');
    final token = await _storage.read(key: 'auth_token');
    final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/pagos/' + paymentId);
    final response = await sl<AuthInterceptorClient>().get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Error al consultar estado de pago: ' + response.statusCode.toString());
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> validateUniversityCode(String code) async {
    try {
      final response = await sl<AuthInterceptorClient>().post(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authUniversitiesValidate}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final university = data['university'];
        
        if (university != null && university['id'] != null) {
          // Save university ID and name in storage for future use
          await _storage.write(key: 'auth_university_id', value: university['id']);
          await _storage.write(key: 'auth_university_name', value: university['name']);
          return true;
        }
      }
      
      _errorMessage = 'Código de universidad inválido';
      notifyListeners();
      return false;
    } catch (e, st) {
      _errorMessage = 'Error al validar el código';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfilePicture(String base64Image) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return false;

      // Actualizar foto en el backend usando Cloudinary
      final response = await sl<AuthInterceptorClient>().put(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authProfilePicture}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageBase64': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns { profile_picture: url } directly
        final newPhotoUrl = data?['profile_picture'] ?? data?['user']?['profile_picture'];
        if (newPhotoUrl != null) {
          if (_currentUser != null) {
            _currentUser = _currentUser!.copyWith(photoUrl: newPhotoUrl);
          }
          await _storage.write(key: 'auth_photo', value: newPhotoUrl);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e, st) {
      return false;
    }
  }

  Future<bool> deleteProfilePicture() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return false;

      final response = await sl<AuthInterceptorClient>().delete(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authProfilePicture}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(photoUrl: '');
        }
        await _storage.delete(key: 'auth_photo');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e, st) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return false;

      final response = await sl<AuthInterceptorClient>().delete(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authDeleteAccount}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await logout();
        return true;
      }
      return false;
    } catch (e, st) {
      return false;
    }
  }
}

