import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/student_directory/data/data_source/clustering_remote_data_source.dart';
import 'package:mobile/core/error/error_handler.dart';
import 'package:mobile/core/error/app_exception.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';

class ClusteringProvider extends ChangeNotifier {
  final ClusteringRemoteDataSource remoteDataSource;

  ClusteringProvider({ClusteringRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ClusteringRemoteDataSource(client: sl<AuthInterceptorClient>());

  List<dynamic> _courses = [];
  Map<String, dynamic>? _clusteringSummary;
  Map<String, dynamic>? _studentProfile;
  bool _isLoading = false;
  bool _isProcessingProfile = false;
  String? _errorMessage;

  List<dynamic> get courses => _courses;
  Map<String, dynamic>? get clusteringSummary => _clusteringSummary;
  Map<String, dynamic>? get studentProfile => _studentProfile;
  bool get isLoading => _isLoading;
  bool get isProcessingProfile => _isProcessingProfile;
  String? get errorMessage => _errorMessage;

  Future<void> authenticateClassroom() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.loginClassroom();
      // Handle login response redirect URL or success status if needed
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await remoteDataSource.getClassroomCourses();
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> runClustering(String courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.processClustering(courseId);
      // Immediately load the summary
      await fetchClusteringSummary(courseId);
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchClusteringSummary(String courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clusteringSummary = await remoteDataSource.getClusteringSummary(courseId);
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFullStudentProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await remoteDataSource.getFullStudentProfile();
      if (response['status'] == 'processing') {
        _isProcessingProfile = true;
        _isLoading = false;
        notifyListeners();
        _pollStudentProfile();
      } else {
        _studentProfile = response;
        _isProcessingProfile = false;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      _isLoading = false;
      _isProcessingProfile = false;
      notifyListeners();
    }
  }

  void _pollStudentProfile() async {
    while (_isProcessingProfile) {
      await Future.delayed(const Duration(seconds: 5));
      try {
        final response = await remoteDataSource.getFullStudentProfile();
        if (response['status'] != 'processing') {
          _studentProfile = response;
          _isProcessingProfile = false;
          notifyListeners();
          break;
        }
      } catch (e, st) {
        _errorMessage = mapErrorToMessage(e, stackTrace: st);
        _isProcessingProfile = false;
        notifyListeners();
        break;
      }
    }
  }
}
