import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_in_with_google_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthProvider({required this.signInWithGoogleUseCase});

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _cachedRole;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get role => _currentUser?.role ?? _cachedRole;
  String? get errorMessage => _errorMessage;

  // Verifica si hay un token guardado al iniciar la app
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      final savedRole = await _storage.read(key: 'auth_role');
      
      if (token != null) {
        _cachedRole = savedRole;
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
      
      // Guardar el token de forma segura
      if (user.token != null) {
        await _storage.write(key: 'auth_token', value: user.token);
      }
      if (user.role != null) {
        await _storage.write(key: 'auth_role', value: user.role);
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'auth_role');
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
