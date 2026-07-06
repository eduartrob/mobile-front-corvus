import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/features/student_directory/data/data_source/clustering_remote_data_source.dart';

class ClusteringProvider extends ChangeNotifier {
  final ClusteringRemoteDataSource remoteDataSource;

  ClusteringProvider({ClusteringRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ClusteringRemoteDataSource(client: http.Client());

  List<dynamic> _courses = [];
  Map<String, dynamic>? _clusteringSummary;
  Map<String, dynamic>? _studentProfile;
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get courses => _courses;
  Map<String, dynamic>? get clusteringSummary => _clusteringSummary;
  Map<String, dynamic>? get studentProfile => _studentProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> authenticateClassroom() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.loginClassroom();
      // Handle login response redirect URL or success status if needed
    } catch (e) {
      _errorMessage = e.toString();
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
    } catch (e) {
      _errorMessage = e.toString();
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
    } catch (e) {
      _errorMessage = e.toString();
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
    } catch (e) {
      _errorMessage = e.toString();
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
      _studentProfile = await remoteDataSource.getFullStudentProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
