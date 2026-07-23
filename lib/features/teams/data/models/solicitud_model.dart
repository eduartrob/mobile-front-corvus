import 'package:mobile/features/student_directory/domain/entities/student.dart';

enum SolicitudState {
  recibida,
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

  factory Solicitud.fromJson(Map<String, dynamic> json, {SolicitudState? forcedState}) {
    SolicitudState state;
    if (forcedState != null) {
      state = forcedState;
    } else {
      final stateStr = json['state']?.toString().toLowerCase() ?? 
                       json['status']?.toString().toLowerCase() ?? 'enviada';
      state = (stateStr == 'aceptada' || stateStr == 'accepted' || stateStr == 'approved' || stateStr == 'pendiente' || stateStr == 'recibida')
          ? SolicitudState.recibida
          : SolicitudState.enviada;
    }

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
        tags: json['tags'] != null 
            ? List<String>.from(json['tags']) 
            : json['habilidades'] != null 
                ? List<String>.from(json['habilidades'])
                : [],
        avatarUrl: json['avatarUrl'] ?? json['foto'] ?? '',
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
