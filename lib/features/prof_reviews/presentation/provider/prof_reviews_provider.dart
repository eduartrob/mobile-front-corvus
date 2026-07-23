import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/prof_reviews/data/models/final_review_model.dart';
import 'package:mobile/features/prof_reviews/data/prof_reviews_remote_data_source.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/error/error_handler.dart';
import 'package:mobile/core/error/app_exception.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';

class ProfReviewsProvider extends ChangeNotifier {
  final ProfReviewsRemoteDataSource _dataSource;

  ProfReviewsProvider({ProfReviewsRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ProfReviewsRemoteDataSource(client: sl<AuthInterceptorClient>());

  List<FinalReviewModel> _reviews = [];
  List<FinalReviewModel> get reviews => _reviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _lastProjectId;

  void clear() {
    _reviews = [];
    _lastProjectId = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchReviews({String? projectId}) async {
    if (_isLoading && projectId == _lastProjectId) return;

    if (projectId != null && projectId != _lastProjectId) {
      _reviews = [];
      _lastProjectId = projectId;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _dataSource.getFinalReviews(projectId: projectId);
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String reviewId, String status, {String? appointmentDate, String? locationLink, String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _dataSource.updateReviewStatus(
        reviewId, 
        status, 
        appointmentDate: appointmentDate,
        locationLink: locationLink,
        reason: reason
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
        sl<AuthInterceptorClient>().post(
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
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> evaluateProject(String reviewId, String comment, bool isApproved) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _dataSource.evaluateProject(reviewId, comment, isApproved);
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = updated;
      }
      return true;
    } catch (e, st) {
      _errorMessage = mapErrorToMessage(e, stackTrace: st);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
