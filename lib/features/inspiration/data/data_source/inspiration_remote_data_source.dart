import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/inspiration/data/models/project_model.dart';

class InspirationRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage _storage;
  static const String _cacheKey = 'cached_blue_oceans';

  InspirationRemoteDataSource({required this.client, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<List<ProjectModel>> getUnexploredProjects({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Retornar caché si existe y no forzamos refresh
    if (!forceRefresh) {
      final cachedStr = prefs.getString(_cacheKey);
      if (cachedStr != null) {
        try {
          final List<dynamic> decoded = json.decode(cachedStr);
          final cachedModels = decoded.map((e) => ProjectModel.fromJson(e)).toList();
          return cachedModels;
        } catch (e) {
          debugPrint('Error leyendo caché de Océanos Azules: $e');
        }
      }
    }

    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/blue-ocean-niches');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

      var token = await _storage.read(key: 'auth_token');
      if (token == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        token = await _storage.read(key: 'auth_token');
      }

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> nichesJson = data['niches'] ?? [];

        if (nichesJson.isNotEmpty) {
          final models = nichesJson.map((niche) => ProjectModel.fromJson(niche)).toList();
          
          // Guardamos en caché
          prefs.setString(_cacheKey, json.encode(models.map((m) => m.toJson()).toList()));
          
          return models;
        }
      }
      debugPrint('InspirationRemoteDataSource: ${response.statusCode}. Usando fallback.');
    } catch (e) {
      debugPrint('InspirationRemoteDataSource Error: $e. Usando fallback.');
    }

    // Fallback con datos de demostración (viewCounts variados para probar la UI)
    final fallback = [
      ProjectModel(
        id: '1',
        category: 'BIOMEDICINA + IA',
        categoryIcon: 'biotech',
        title: 'Diagnóstico Temprano mediante Análisis Espectral',
        description: 'Combinación de visión por computadora y espectroscopía de bajo costo para detectar patologías cutáneas en áreas rurales.',
        status: 'Alto Potencial',
        viewCount: 8,
        userAvatars: const ['https://ui-avatars.com/api/?name=Bio+AI&background=0D8ABC&color=fff'],
        recentViewers: const [
          'https://ui-avatars.com/api/?name=Ana+L&background=7B61FF&color=fff',
          'https://ui-avatars.com/api/?name=Carlos+M&background=FF6B35&color=fff',
        ],
        analysisStatus: 'pending',
      ),
      ProjectModel(
        id: '2',
        category: 'ENERGÍA RENOVABLE',
        categoryIcon: 'auto_awesome',
        title: 'Optimización de Micro-redes Solares Urbanas',
        description: 'Algoritmos de aprendizaje reforzado para predecir la demanda energética comunitaria y redistribuir flujo eléctrico.',
        status: 'Inexplorado',
        viewCount: 3,
        userAvatars: const ['https://ui-avatars.com/api/?name=Solar+Net&background=2E7D32&color=fff'],
        recentViewers: const [
          'https://ui-avatars.com/api/?name=Sofia+R&background=E91E63&color=fff',
        ],
        analysisStatus: 'completed',
        analysisData: {
          'hallazgo_principal': 'Existe un vacío importante en algoritmos de refuerzo aplicados específicamente a micro-redes en climas tropicales con alta variabilidad de nubes.',
          'sugerencias': [
            {'titulo': 'Simulación Híbrida', 'descripcion': 'Combinar datos meteorológicos en tiempo real con modelos de consumo estocástico.', 'tipo': 'Recomendado'},
            {'titulo': 'Estudio Comparativo', 'descripcion': 'Comparar eficiencia frente a controladores PID tradicionales.', 'tipo': 'Alternativo'}
          ],
          'metricas': {'originalidad': 92, 'disponibilidad_datos': 65, 'relevancia_academica': 88}
        }
      ),
      ProjectModel(
        id: '3',
        category: 'SEGURIDAD + RAG',
        categoryIcon: 'auto_awesome',
        title: 'Auditoría Automática de Contratos Inteligentes',
        description: 'Sistema RAG especializado en detectar vulnerabilidades reentrantes en código Solidity antes del despliegue en mainnet.',
        status: 'Tendencia',
        viewCount: 97,
        userAvatars: const ['https://ui-avatars.com/api/?name=Sec+RAG&background=D32F2F&color=fff'],
        recentViewers: const [
          'https://ui-avatars.com/api/?name=Luis+G&background=FF5722&color=fff',
          'https://ui-avatars.com/api/?name=Maria+V&background=9C27B0&color=fff',
          'https://ui-avatars.com/api/?name=Pedro+K&background=00BCD4&color=fff',
        ],
        analysisStatus: 'completed',
        analysisData: {
          'hallazgo_principal': 'Casi no hay implementaciones de RAG puro para contratos inteligentes que incluyan bases de datos actualizadas con los exploits de 2024.',
          'sugerencias': [
            {'titulo': 'Framework Evaluación de Seguridad', 'descripcion': 'Crear un benchmark de contratos vulnerables para medir el modelo RAG.', 'tipo': 'Recomendado'}
          ],
          'metricas': {'originalidad': 75, 'disponibilidad_datos': 95, 'relevancia_academica': 90}
        }
      ),
    ];

    fallback.sort((a, b) => a.viewCount.compareTo(b.viewCount));
    
    // Guardamos fallback en caché
    prefs.setString(_cacheKey, json.encode(fallback.map((m) => m.toJson()).toList()));
    
    return fallback;
  }

  /// Registra una vista en el backend y devuelve la data actualizada (incluyendo el análisis)
  Future<ProjectModel?> trackNicheView(String nicheId, String? userAvatar) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/blue-ocean-niches/$nicheId/view');
    
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final token = await _storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = json.encode({
        'user_avatar': userAvatar
      });

      final response = await client.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'success') {
          // Actualizamos la caché local modificando el item específico
          final prefs = await SharedPreferences.getInstance();
          final cachedStr = prefs.getString(_cacheKey);
          
          if (cachedStr != null) {
            final List<dynamic> decoded = json.decode(cachedStr);
            final List<ProjectModel> cachedModels = decoded.map((e) => ProjectModel.fromJson(e)).toList();
            
            final index = cachedModels.indexWhere((m) => m.id == nicheId);
            if (index != -1) {
              final model = cachedModels[index];
              
              // Evitar duplicados en la lista de viewers
              final newViewers = List<String>.from(model.recentViewers);
              if (userAvatar != null) {
                newViewers.remove(userAvatar);
                newViewers.insert(0, userAvatar);
                if (newViewers.length > 3) newViewers.removeLast();
              }
              
              final updatedModel = ProjectModel(
                id: model.id,
                category: model.category,
                categoryIcon: model.categoryIcon,
                title: model.title,
                description: model.description,
                status: model.status,
                userAvatars: model.userAvatars,
                viewCount: data['view_count'] ?? (model.viewCount + 1),
                recentViewers: newViewers,
                analysisStatus: data['analysis_status'] ?? model.analysisStatus,
                analysisData: data['analysis_data'] ?? model.analysisData,
              );
              
              cachedModels[index] = updatedModel;
              prefs.setString(_cacheKey, json.encode(cachedModels.map((m) => m.toJson()).toList()));
              
              return updatedModel;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error en trackNicheView: $e');
    }
    return null;
  }


  /// Genera avatares de "vistos recientemente" basados en el número de vistas
  static List<String> _generateRecentViewers(int viewCount) {
    if (viewCount == 0) return [];
    final names = ['Ana L', 'Carlos M', 'Sofia R', 'Luis G', 'Maria V', 'Pedro K', 'Diana F'];
    final colors = ['7B61FF', 'FF6B35', 'E91E63', 'FF5722', '9C27B0', '00BCD4', '2E7D32'];
    final count = viewCount > 50 ? 3 : viewCount > 20 ? 2 : 1;
    return List.generate(count.clamp(0, names.length), (i) =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(names[i])}&background=${colors[i]}&color=fff'
    );
  }
}
