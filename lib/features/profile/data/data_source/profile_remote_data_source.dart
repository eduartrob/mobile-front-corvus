import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/profile/data/models/profile_completo_model.dart';

class ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSource({required this.client});

  Future<ProfileCompletoModel> getPerfilCompleto({bool forceRefresh = false}) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/mi-perfil/completo${forceRefresh ? "?force_refresh=true" : ""}');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        return ProfileCompletoModel.fromJson(body);
      } else {
        final bodyText = utf8.decode(response.bodyBytes);
        final errorJson = json.decode(bodyText);
        throw Exception(errorJson['detail'] ?? errorJson['message'] ?? 'Error del servidor (${response.statusCode})');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
