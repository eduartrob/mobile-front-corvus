import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

class NotificationsRemoteDataSource {
  final http.Client client;

  NotificationsRemoteDataSource({required this.client});

  Future<List<dynamic>> fetchMyNotifications() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/my-notifications');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final bodyText = utf8.decode(response.bodyBytes);
        return json.decode(bodyText) as List<dynamic>;
      }
      throw Exception('Failed to load notifications: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/$id/read');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.put(url, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/$id');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.delete(url, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  Future<void> deleteBulk(List<String> ids) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/bulk');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final body = json.encode({"ids": ids});
      final response = await client.delete(url, headers: headers, body: body).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Failed to bulk delete notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error bulk deleting notifications: $e');
    }
  }

  Future<void> deleteAll() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final response = await client.delete(url, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete all notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting all notifications: $e');
    }
  }
}
