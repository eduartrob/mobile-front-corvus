import 'package:flutter/foundation.dart';
import '../../domain/entities/student.dart';

class StudentDirectoryProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedSkill = 'All Skills';

  String get searchQuery => _searchQuery;
  String get selectedSkill => _selectedSkill;

  final List<Student> _students = const [
    Student(
      name: 'Elena Rodríguez',
      username: '@elena_dev',
      bio: 'Full-stack developer passionate about building scalable RAG applications and UI/UX',
      tags: ['React', 'TypeScript', 'UI/UX'],
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    ),
    Student(
      name: 'Marcus Chen',
      username: '@marcus_codes',
      bio: 'Backend engineer specialized in Go, Python, and distributed systems architecture.',
      tags: ['Go', 'Python', 'gRPC'],
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    Student(
      name: 'Sophia Patel',
      username: '@sophia_data',
      bio: 'Data Scientist focused on NLP, machine learning pipelines, and vector databases.',
      tags: ['Python', 'PyTorch', 'NLP'],
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    ),
    Student(
      name: 'Mateo Ruiz',
      username: '@mateo_ux',
      bio: 'Product designer creating clean, accessible, and user-centered digital experiences.',
      tags: ['Figma', 'UI/UX', 'Research'],
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    ),
    Student(
      name: 'Carlos Mendoza',
      username: '@carlos_dev',
      bio: 'Mobile developer specializing in Flutter and Native iOS development.',
      tags: ['Flutter', 'Dart', 'iOS'],
      avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
    ),
    Student(
      name: 'Ana Gómez',
      username: '@ana_ai',
      bio: 'AI researcher interested in Generative AI, Large Language Models, and Prompt Engineering.',
      tags: ['Python', 'AI/ML', 'NLP'],
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    ),
  ];

  final List<String> _skills = const [
    'All Skills',
    'React',
    'Python',
    'AI/ML',
    'UI/UX',
    'Flutter',
    'Go',
  ];

  List<Student> get students => _students;
  List<String> get skills => _skills;

  List<Student> get filteredStudents {
    return _students.where((student) {
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
