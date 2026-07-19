import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/prof_history/data/models/activity_log_model.dart';

class ProfHistoryProvider extends ChangeNotifier {
  final http.Client client;

  ProfHistoryProvider({required this.client});

  List<ActivityLogModel> _history = [];
  List<ActivityLogModel> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.professorsHistory}');
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> logs = data['history'] ?? [];
        _history = logs.map((json) => ActivityLogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
