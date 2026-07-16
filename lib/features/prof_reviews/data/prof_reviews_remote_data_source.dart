import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/prof_reviews/data/models/final_review_model.dart';

class ProfReviewsRemoteDataSource {
  final http.Client client;

  ProfReviewsRemoteDataSource({required this.client});

  Future<List<FinalReviewModel>> getFinalReviews({String? projectId}) async {
    final urlStr = projectId != null 
        ? '${ApiConfig.apiGatewayUrl}/final-reviews?projectId=$projectId'
        : '${ApiConfig.apiGatewayUrl}/final-reviews';
    final url = Uri.parse(urlStr);

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> reviewsJson = data['reviews'] ?? [];
        return reviewsJson.map((json) => FinalReviewModel.fromJson(json)).toList();
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

  Future<FinalReviewModel> updateReviewStatus(
    String id, 
    String status, 
    {String? appointmentDate, String? locationLink, String? reason}
  ) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/final-reviews/$id/status');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      headers['Content-Type'] = 'application/json';

      final bodyMap = <String, dynamic>{'status': status};
      if (appointmentDate != null) bodyMap['appointment_date'] = appointmentDate;
      if (locationLink != null) bodyMap['location_link'] = locationLink;
      if (reason != null) bodyMap['reason'] = reason;

      final response = await client.patch(url, headers: headers, body: jsonEncode(bodyMap)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return FinalReviewModel.fromJson(data['review']);
      } else {
        final bodyText = utf8.decode(response.bodyBytes);
        try {
          final errorJson = json.decode(bodyText);
          final errors = errorJson['errors'] != null ? ' - ${jsonEncode(errorJson['errors'])}' : '';
          throw Exception('${errorJson['message'] ?? bodyText}$errors');
        } catch (e) {
          if (e is FormatException) {
            throw Exception(bodyText);
          }
          rethrow;
        }
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }

  Future<FinalReviewModel> evaluateProject(
    String id, 
    String comment, 
    bool isApproved
  ) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/final-reviews/$id/evaluate');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      headers['Content-Type'] = 'application/json';

      final bodyMap = <String, dynamic>{
        'comment': comment,
        'is_approved': isApproved,
      };

      final response = await client.post(url, headers: headers, body: jsonEncode(bodyMap)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return FinalReviewModel.fromJson(data['review']);
      } else {
        final bodyText = utf8.decode(response.bodyBytes);
        try {
          final errorJson = json.decode(bodyText);
          final errors = errorJson['errors'] != null ? ' - ${jsonEncode(errorJson['errors'])}' : '';
          throw Exception('${errorJson['message'] ?? bodyText}$errors');
        } catch (e) {
          if (e is FormatException) {
            throw Exception(bodyText);
          }
          rethrow;
        }
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }
}
