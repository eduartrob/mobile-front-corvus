import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/inspiration/data/models/project_model.dart';

class InspirationRemoteDataSource {
  final http.Client client;
  static const String _cacheKey = 'cached_blue_oceans';
  static const String _cacheTimestampKey = 'cached_blue_oceans_timestamp';
  static const int _cacheTtlMinutes = 30; // Invalidar cache cada 30 minutos

  InspirationRemoteDataSource({required this.client});

  Future<List<ProjectModel>> getUnexploredProjects({
    bool forceRefresh = false,
    int page = 1,
    int limit = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Only use cache for the first page
    if (!forceRefresh && page == 1) {
      final cachedStr = prefs.getString(_cacheKey);
      final cachedTimestamp = prefs.getInt(_cacheTimestampKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final ageMinutes = (now - cachedTimestamp) / 60000;

      // Usar cache solo si existe Y tiene menos de 30 minutos
      if (cachedStr != null && ageMinutes < _cacheTtlMinutes) {
        try {
          final List<dynamic> decoded = json.decode(cachedStr);
          return decoded.map((e) => ProjectModel.fromJson(e)).toList();
        } catch (e) {
          debugPrint('error leyendo cache de oceanos azules: $e');
        }
      }
    }

    final url = Uri.parse(
        '${ApiConfig.apiGatewayUrl}/clustering/integrator/blue-ocean-niches?page=$page&limit=$limit');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> nichesJson = data['niches'] ?? [];
        final models = nichesJson.map((niche) => ProjectModel.fromJson(niche)).toList();
        
        // Only update cache if fetching the first page
        if (page == 1) {
          prefs.setString(_cacheKey, json.encode(models.map((m) => m.toJson()).toList()));
          prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
        }
        
        return models;
      }
      debugPrint('InspirationRemoteDataSource: HTTP ${response.statusCode}');
    } catch (e) {
      debugPrint('InspirationRemoteDataSource Error: $e');
      // Si falla la red, intentar devolver cache aunque sea antigua, pero solo para la primera pagina
      if (page == 1) {
        final cachedStr = prefs.getString(_cacheKey);
        if (cachedStr != null) {
          try {
            final List<dynamic> decoded = json.decode(cachedStr);
            return decoded.map((e) => ProjectModel.fromJson(e)).toList();
          } catch (_) {}
        }
      }
    }

    return [];
  }

  Future<ProjectModel?> trackNicheView(String nicheId, String? userAvatar) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/blue-ocean-niches/$nicheId/view');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final body = json.encode({'user_avatar': userAvatar});
      final response = await client.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          final cachedStr = prefs.getString(_cacheKey);

          if (cachedStr != null) {
            final List<dynamic> decoded = json.decode(cachedStr);
            final List<ProjectModel> cachedModels = decoded.map((e) => ProjectModel.fromJson(e)).toList();
            final index = cachedModels.indexWhere((m) => m.id == nicheId);

            if (index != -1) {
              final model = cachedModels[index];
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

  static List<String> _generateRecentViewers(int viewCount) {
    if (viewCount == 0) return [];
    final names = ['Ana L', 'Carlos M', 'Sofia R', 'Luis G', 'Maria V', 'Pedro K', 'Diana F'];
    final colors = ['7B61FF', 'FF6B35', 'E91E63', 'FF5722', '9C27B0', '00BCD4', '2E7D32'];
    final count = viewCount > 50 ? 3 : viewCount > 20 ? 2 : 1;
    return List.generate(count.clamp(0, names.length), (i) =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(names[i])}&background=${colors[i]}&color=fff'
    );
  }

  Future<String> validateIdea(String idea) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/validate-idea');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final body = json.encode({'idea': idea});
      final response = await client.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['result'] ?? 'Sin respuesta.';
      } else {
        return 'Ocurrió un error de conexión al validar la idea.';
      }
    } catch (e) {
      debugPrint('Error en validateIdea: $e');
      return 'Error al validar la idea. Inténtalo más tarde.';
    }
  }
}
