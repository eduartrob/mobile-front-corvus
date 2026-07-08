import 'package:flutter/foundation.dart';
import '../../domain/entities/student.dart';

class StudentDirectoryProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedSkill = 'All Skills';

  String get searchQuery => _searchQuery;
  String get selectedSkill => _selectedSkill;

  final TeamsRemoteDataSource _remoteDataSource;
  List<Student> _allStudents = [];
  bool _isLoading = false;
  String _error = '';

  StudentDirectoryProvider({required TeamsRemoteDataSource remoteDataSource}) 
    : _remoteDataSource = remoteDataSource {
    _fetchStudents();
  }

  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> _fetchStudents() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _allStudents = await _remoteDataSource.getStudentDirectory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _fetchStudents();
  }

  List<String> get skills => [
    'All Skills',
    'React',
    'Python',
    'AI/ML',
    'UI/UX',
    'Flutter',
    'Go',
  ];

  List<Student> get filteredStudents {
    return _allStudents.where((student) {
      final matchesSearch = student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.bio.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesSkill = _selectedSkill == 'All Skills' ||
          student.tags.contains(_selectedSkill);

      return matchesSearch && matchesSkill;
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectSkill(String skill) {
    _selectedSkill = skill;
    notifyListeners();
  }
}
