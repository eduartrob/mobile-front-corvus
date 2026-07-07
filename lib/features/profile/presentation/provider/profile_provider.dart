import 'package:flutter/foundation.dart';
import 'package:mobile/features/profile/data/data_source/profile_remote_data_source.dart';
import 'package:mobile/features/profile/data/models/profile_completo_model.dart';
import 'package:http/http.dart' as http;

class ProfileProvider extends ChangeNotifier {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileProvider({ProfileRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource(client: http.Client());

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
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
