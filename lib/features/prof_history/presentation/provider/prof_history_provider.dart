import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/prof_history/data/models/activity_log_model.dart';
import 'package:mobile/core/error/error_handler.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/core/di/di.dart';

// Definición manual tradicional del NotifierProvider de Riverpod
final profHistoryProvider = NotifierProvider<ProfHistoryNotifier, AsyncValue<List<ActivityLogModel>>>(() {
  return ProfHistoryNotifier();
});

class ProfHistoryNotifier extends Notifier<AsyncValue<List<ActivityLogModel>>> {
  late final http.Client _client;

  @override
  AsyncValue<List<ActivityLogModel>> build() {
    _client = sl<AuthInterceptorClient>();
    return const AsyncValue.loading();
  }

  Future<void> fetchHistory() async {
    state = const AsyncValue.loading();

    try {
      final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.professorsHistory}');
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

      final response = await _client.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> logs = data['history'] ?? [];
        final historyList = logs.map((json) => ActivityLogModel.fromJson(json)).toList();
        state = AsyncValue.data(historyList);
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e, st) {
      final errorMessage = mapErrorToMessage(e, stackTrace: st);
      state = AsyncValue.error(errorMessage, st);
    }
  }
}
