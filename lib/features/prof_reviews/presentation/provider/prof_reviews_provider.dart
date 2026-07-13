import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/prof_reviews/data/models/final_review_model.dart';
import 'package:mobile/features/prof_reviews/data/prof_reviews_remote_data_source.dart';
import 'package:intl/intl.dart';

class ProfReviewsProvider extends ChangeNotifier {
  final ProfReviewsRemoteDataSource _dataSource;

  ProfReviewsProvider({ProfReviewsRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ProfReviewsRemoteDataSource(client: apiClient);

  List<FinalReviewModel> _reviews = [];
  List<FinalReviewModel> get reviews => _reviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _dataSource.getFinalReviews();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String reviewId, String status, {String? appointmentDate, String? locationLink}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _dataSource.updateReviewStatus(
        reviewId, 
        status, 
        appointmentDate: appointmentDate,
        locationLink: locationLink
      );
      
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = updated;
      }
      
      try {
        String body = 'Tu propuesta ha sido actualizada.';
        if (status == 'APPROVED') body = '¡Felicidades! Tu propuesta ha sido APROBADA.';
        if (status == 'REJECTED') body = 'Tu propuesta ha sido RECHAZADA.';
        if (status == 'SUMMONED') {
          body = 'Has sido CITADO para revisión.';
          if (updated.appointmentDate != null) {
            body = 'Has sido CITADO para revisión el ${DateFormat('dd/MM/yyyy - hh:mm a').format(updated.appointmentDate!.toLocal())}.';
          }
        }
        
        final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/topic/push');
        apiClient.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'topic': 'user_${updated.studentId}',
            'title': 'Actualización de Propuesta',
            'body': body,
            'data': {
              'type': 'info'
            }
          })
        ).catchError((_) => null); // Ignore if push fails
      } catch (_) {}
      
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
