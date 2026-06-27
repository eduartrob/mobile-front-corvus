import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/features/inspiration/data/models/project_model.dart';

class InspirationRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage _storage;

  InspirationRemoteDataSource({required this.client, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<List<ProjectModel>> getUnexploredProjects() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/blue-ocean-niches');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> nichesJson = data['niches'] ?? [];
        
        return List.generate(nichesJson.length, (index) {
          final niche = nichesJson[index];
          return ProjectModel(
            id: index.toString(),
            category: niche['category'] ?? 'INNOVACIÓN',
            categoryIcon: 'auto_awesome', // Icono por defecto para océanos azules
            title: niche['title'] ?? 'Océano Azul',
            description: niche['description'] ?? '',
            status: niche['tag'] ?? 'Inexplorado',
            userAvatars: [
              'https://ui-avatars.com/api/?name=C&background=0D8ABC&color=fff',
              'https://ui-avatars.com/api/?name=AI&background=random'
            ],
          );
        });
      } else {
        throw Exception('Error al obtener océanos azules desde el servidor');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
