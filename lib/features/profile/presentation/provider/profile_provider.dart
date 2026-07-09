import 'package:flutter/foundation.dart';
import 'package:mobile/features/profile/data/data_source/profile_remote_data_source.dart';
import 'package:mobile/features/profile/data/models/profile_completo_model.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/auth_interceptor_client.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileProvider({ProfileRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource(client: apiClient);

  ProfileCompletoModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileCompletoModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await remoteDataSource.getPerfilCompleto(forceRefresh: forceRefresh);
      if (_profile != null && _profile!.isProcessing) {
        _isLoading = false;
        notifyListeners();
        _pollProfile();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
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
      } catch (e) {
        _errorMessage = e.toString();
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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.updateProfile(
        fullName: fullName,
        enrollmentId: enrollmentId,
        semester: semester,
        skills: skills,
      );
      await fetchProfile(forceRefresh: true);
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<void> requestVerificationCode(String type) async {
    try {
      await remoteDataSource.requestVerificationCode(type);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> confirmVerificationCode(String code, String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.confirmVerificationCode(code, type);
      await fetchProfile(forceRefresh: true);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString());
    }
  }

  Future<void> linkGoogleAccount(String authCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.linkGoogleAccount(authCode);
      await fetchProfile(forceRefresh: true);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString());
    }
  }

  Future<void> addSecondaryEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.addSecondaryEmail(email);
      await fetchProfile(forceRefresh: true);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString());
    }
  }

  Future<void> deleteEmail(String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.deleteEmail(type);
      await fetchProfile(forceRefresh: true);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString());
    }
  }
}
