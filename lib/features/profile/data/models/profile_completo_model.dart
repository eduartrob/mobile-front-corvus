class HabilidadModel {
  final String habilidad;
  final String nivel;
  final int porcentaje;
  final List<String> materias;

  HabilidadModel({
    required this.habilidad,
    required this.nivel,
    required this.porcentaje,
    required this.materias,
  });

  factory HabilidadModel.fromJson(Map<String, dynamic> json) {
    var materiasList = json['materias'] as List? ?? [];
    return HabilidadModel(
      habilidad: json['habilidad']?.toString() ?? '',
      nivel: json['nivel']?.toString() ?? '',
      porcentaje: json['porcentaje'] is int 
          ? json['porcentaje'] 
          : (double.tryParse(json['porcentaje']?.toString() ?? '0')?.toInt() ?? 0),
      materias: materiasList.map((m) => m.toString()).toList(),
    );
  }
}

class ProfileCompletoModel {
  final String alumno;
  final String? correo;
  final String? universidad;
  final String? carrera;
  final String? cuatrimestre;
  final Map<String, dynamic> resumen;
  final List<dynamic> documentosConIa;
  final List<dynamic> materias;
  final List<HabilidadModel> habilidades;
  final bool isProcessing;

  final double? progress;
  final String? message;
  final String? matricula;
  final bool isVerified;
  ProfileCompletoModel({
    required this.alumno,
    this.correo,
    this.universidad,
    this.carrera,
    this.cuatrimestre,
    this.matricula,
    this.isVerified = false,
    required this.resumen,
    required this.documentosConIa,
    required this.materias,
    required this.habilidades,
    this.isProcessing = false,
    this.progress,
    this.message,
  });

  factory ProfileCompletoModel.fromJson(Map<String, dynamic> json) {
    var habilidadesList = json['habilidades'] as List? ?? [];
    return ProfileCompletoModel(
      alumno: json['alumno']?.toString() ?? '',
      correo: json['correo']?.toString(),
      universidad: json['universidad']?.toString(),
      carrera: json['carrera']?.toString(),
      cuatrimestre: json['cuatrimestre']?.toString(),
      matricula: json['matricula']?.toString(),
      isVerified: json['is_verified'] ?? false,
      resumen: json['resumen'] as Map<String, dynamic>? ?? {},
      documentosConIa: json['documentos_con_ia'] as List? ?? [],
      materias: json['materias'] as List? ?? [],
      habilidades: habilidadesList.map((h) => HabilidadModel.fromJson(h)).toList(),
      isProcessing: json['status'] == 'processing',
      progress: json['progress'] is int ? (json['progress'] as int).toDouble() : (json['progress'] as double?),
      message: json['message']?.toString(),
    );
  }
}

