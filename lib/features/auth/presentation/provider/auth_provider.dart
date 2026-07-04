import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_in_with_google_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/request_drive_scope_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/get_drive_access_token_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/request_classroom_scopes_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_out_from_google_usecase.dart';
import 'package:mobile/core/services/notification_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final RequestDriveScopeUseCase requestDriveScopeUseCase;
  final RequestClassroomScopesUseCase requestClassroomScopesUseCase;
  final GetDriveAccessTokenUseCase getDriveAccessTokenUseCase;
  final SignOutFromGoogleUseCase signOutFromGoogleUseCase;
  final FlutterSecureStorage _storage;

  AuthProvider({
    required this.signInWithGoogleUseCase,
    required this.requestDriveScopeUseCase,
    required this.requestClassroomScopesUseCase,
    required this.getDriveAccessTokenUseCase,
    required this.signOutFromGoogleUseCase,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

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
        await _storage.write(key: 'auth_token', value: user.token);
      }
      if (user.role != null) {
        await _storage.write(key: 'auth_role', value: user.role);
      }
      await _storage.write(key: 'auth_id', value: user.id);
      await _storage.write(key: 'auth_email', value: user.email);
      await _storage.write(key: 'auth_name', value: user.name);
      if (user.photoUrl != null) {
        await _storage.write(key: 'auth_photo', value: user.photoUrl);
      }

      await NotificationService().requestPermission();

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      String errorStr = e.toString();
      if (errorStr.contains('403') || errorStr.toLowerCase().contains('upchiapas') || errorStr.toLowerCase().contains('domain') || errorStr.toLowerCase().contains('permitido')) {
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

  Future<bool> requestClassroomAccess() async {
    try {
      return await requestClassroomScopesUseCase();
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
