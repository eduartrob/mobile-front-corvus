import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

class MyProjectRemoteDataSource {
  final http.Client client;

  MyProjectRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> preValidateProposal(String filePath, String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/pre-validate-proposal');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['user_id'] = userId;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      // Do NOT addAll(ApiConfig.defaultHeaders) because it overwrites the multipart boundary Content-Type
      request.headers['Accept'] = 'application/json';

      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        final bodyText = utf8.decode(response.bodyBytes);
        try {
          final errorJson = json.decode(bodyText);
          throw Exception(errorJson['detail'] ?? errorJson['message'] ?? bodyText);
        } catch (_) {
          throw Exception(bodyText);
        }
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> checkDraft(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/draft-proposal/$userId');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'not_found') return {};
        return data;
      } else {
        final bodyText = utf8.decode(response.bodyBytes);
        try {
          final errorJson = json.decode(bodyText);
          throw Exception(errorJson['detail'] ?? errorJson['message'] ?? 'Error al consultar borrador');
        } catch (_) {
          throw Exception('Error al consultar borrador');
        }
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> getAnalysisStatus(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/analysis-status/$userId');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    return {'phase': 0, 'message': ''};
  }

  Future<void> analyzeDraftDetailed(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/analyze-draft-proposal');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['user_id'] = userId;
      request.headers['Accept'] = 'application/json';

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final bodyText = utf8.decode(response.bodyBytes);
        try {
          final errorJson = json.decode(bodyText);
          throw Exception(errorJson['detail'] ?? bodyText);
        } catch (_) {
          throw Exception(bodyText);
        }
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> getAnalysisResult(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/analysis-result/$userId');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    return {'status': 'pending'};
  }

  Future<void> cancelAnalysis(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/cancel-analysis/$userId');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      await client.post(url, headers: headers);
    } catch (_) {}
  }

  Future<Map<String, dynamic>> sendFinalReview(String teamId, Map<String, dynamic> proposalData) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/final-reviews');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      headers['Content-Type'] = 'application/json';

      final body = jsonEncode({
        'team_id': teamId,
        'proposal_data': proposalData,
      });

      final response = await client.post(url, headers: headers, body: body).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        final bodyText = utf8.decode(response.bodyBytes);
        try {
          final errorJson = json.decode(bodyText);
          throw Exception(errorJson['message'] ?? bodyText);
        } catch (_) {
          throw Exception(bodyText);
        }
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>?> getFinalReviewStatus(String teamId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/final-reviews/team/$teamId');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes))['review'];
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
