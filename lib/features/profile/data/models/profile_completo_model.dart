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
  final Map<String, dynamic> resumen;
  final List<dynamic> documentosConIa;
  final List<dynamic> materias;
  final List<HabilidadModel> habilidades;
  
  // Soporte para procesamiento asíncrono
  final String? status;
  final double? progress;
  final String? message;

  ProfileCompletoModel({
    required this.alumno,
    required this.resumen,
    required this.documentosConIa,
    required this.materias,
    required this.habilidades,
    this.status,
    this.progress,
    this.message,
  });

  factory ProfileCompletoModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString();
    var habilidadesList = json['habilidades'] as List? ?? [];
    
    double? progVal;
    if (json['progress'] != null) {
      progVal = double.tryParse(json['progress'].toString());
      if (progVal != null && progVal > 1.0) {
        progVal = progVal / 100.0;
      }
    }

    return ProfileCompletoModel(
      status: statusStr,
      progress: progVal,
      message: json['message']?.toString() ?? json['detail']?.toString(),
      alumno: json['alumno']?.toString() ?? '',
      resumen: json['resumen'] as Map<String, dynamic>? ?? {},
      documentosConIa: json['documentos_con_ia'] as List? ?? [],
      materias: json['materias'] as List? ?? [],
      habilidades: habilidadesList.map((h) => HabilidadModel.fromJson(h)).toList(),
    );
  }

  bool get isProcessing => status == 'processing' || status == 'PROCESANDO';
}
