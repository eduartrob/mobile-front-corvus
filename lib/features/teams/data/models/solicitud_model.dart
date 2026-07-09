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

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    final stateStr = json['state']?.toString().toLowerCase() ?? 
                     json['status']?.toString().toLowerCase() ?? 'enviada';
    final state = (stateStr == 'aceptada' || stateStr == 'accepted' || stateStr == 'approved')
        ? SolicitudState.aceptada
        : SolicitudState.enviada;

    Student studentObj;
    if (json['student'] != null) {
      studentObj = Student.fromJson(json['student']);
    } else if (json['alumno'] != null) {
      studentObj = Student.fromJson(json['alumno']);
    } else {
      studentObj = Student(
        id: json['studentId']?.toString() ?? json['id_usuario']?.toString(),
        name: json['studentName'] ?? json['nombre'] ?? 'Estudiante',
        username: json['studentUsername'] ?? json['usuario'] ?? '@estudiante',
        bio: json['bio'] ?? json['biografia'] ?? '',
        tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
        avatarUrl: json['avatarUrl'] ?? json['foto'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      );
    }

    return Solicitud(
      id: json['id']?.toString() ?? json['requestId']?.toString() ?? '',
      student: studentObj,
      state: state,
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now(),
    );
  }
}
