import 'package:mobile/features/student_directory/domain/entities/student.dart';

enum SolicitudState {
  aceptada,
  enviada,
}

class Solicitud {
  final String id;
  final Student student;
  final SolicitudState state;
  final DateTime date;

  const Solicitud({
    required this.id,
    required this.student,
    required this.state,
    required this.date,
  });
}

final List<Solicitud> mockSolicitudes = [
  Solicitud(
    id: 'sol_1',
    student: const Student(
      name: 'Elena Rodríguez',
      username: '@elena_dev',
      bio: 'Full-stack developer passionate about building scalable RAG applications and UI/UX',
      tags: ['React', 'TypeScript', 'UI/UX'],
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      isVerified: true,
    ),
    state: SolicitudState.aceptada,
    date: DateTime.now(),
  ),
  Solicitud(
    id: 'sol_2',
    student: const Student(
      name: 'Marcus Chen',
      username: '@marcus_codes',
      bio: 'Backend engineer specialized in Go, Python, and distributed systems architecture.',
      tags: ['Go', 'Python', 'gRPC'],
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      isVerified: true,
    ),
    state: SolicitudState.aceptada,
    date: DateTime.now(),
  ),
  Solicitud(
    id: 'sol_3',
    student: const Student(
      name: 'Sophia Patel',
      username: '@sophia_data',
      bio: 'Data Scientist focused on NLP, machine learning pipelines, and vector databases.',
      tags: ['Python', 'PyTorch', 'NLP'],
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      isVerified: true,
    ),
    state: SolicitudState.enviada,
    date: DateTime.now(),
  ),
  Solicitud(
    id: 'sol_4',
    student: const Student(
      name: 'Mateo Ruiz',
      username: '@mateo_ux',
      bio: 'Product designer creating clean, accessible, and user-centered digital experiences.',
      tags: ['Figma', 'UI/UX', 'Research'],
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      isVerified: true,
    ),
    state: SolicitudState.enviada,
    date: DateTime.now(),
  ),
];
