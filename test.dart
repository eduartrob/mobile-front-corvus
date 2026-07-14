import 'dart:convert';

void main() {
  String jsonString = '''{
    "project_sections": [
      {
        "nombre": "Introducción",
        "keywords": [],
        "obligatoria": true,
        "descripcion": "Aquí pondrá la introducción..."
      }
    ]
  }''';

  final data = jsonDecode(jsonString);

  try {
    List<Map<String, dynamic>> projectSections = (data['project_sections'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    print("Success: \$projectSections");
  } catch (e, st) {
    print("Error 1: \$e");
  }
}
