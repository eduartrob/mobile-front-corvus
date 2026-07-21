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

  String? _lastProjectId;

  void clear() {
    _reviews = [];
    _lastProjectId = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchReviews({String? projectId}) async {
    final effectiveProjectId = (projectId != null && projectId.isNotEmpty) ? projectId : _lastProjectId;
    if (effectiveProjectId != null && effectiveProjectId != _lastProjectId) {
      _reviews = [];
    }
    _lastProjectId = effectiveProjectId;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _dataSource.getFinalReviews(projectId: effectiveProjectId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(
    String reviewId, 
    String status, 
    {
      String? appointmentDate, 
      String? locationLink, 
      String? reason,
      bool isEditAppointment = false,
      bool isCancelAppointment = false,
    }
  ) async {
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
        String title = 'Actualización de Propuesta';
        String body = 'Tu propuesta ha sido actualizada.';
        
        if (isCancelAppointment) {
          title = 'Cita Cancelada';
          body = 'su cita fue cancelada';
        } else if (isEditAppointment) {
          title = 'Cita Modificada';
          final dtStr = updated.appointmentDate != null
              ? DateFormat('dd/MM/yyyy - hh:mm a').format(updated.appointmentDate!.toLocal())
              : '';
          body = 'su cita fue modificada a: $dtStr';
        } else if (status == 'SUMMONED') {
          title = 'Cita Programada';
          final dtStr = updated.appointmentDate != null
              ? DateFormat('dd/MM/yyyy - hh:mm a').format(updated.appointmentDate!.toLocal())
              : '';
          body = 'Has sido CITADO para revisión el $dtStr.';
        } else if (status == 'APPROVED') {
          title = 'Propuesta Aprobada';
          body = '¡Felicidades! Tu propuesta ha sido APROBADA.';
          if (reason != null && reason.trim().isNotEmpty) {
            body += '\nComentario del docente: ${reason.trim()}';
          }
        } else if (status == 'REJECTED') {
          title = 'Propuesta Rechazada';
          body = 'Tu propuesta de proyecto ha sido RECHAZADA.';
          if (reason != null && reason.trim().isNotEmpty) {
            body += '\nMotivo: ${reason.trim()}';
          }
        }
        
        final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/topic/push');
        
        // Push directo al estudiante / creador
        apiClient.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'topic': 'user_${updated.studentId}',
            'title': title,
            'body': body,
            'data': {'type': 'info', 'title': title, 'message': body}
          })
        ).catchError((_) => null);
        
        // Push directo al canal del equipo
        if (updated.teamId.isNotEmpty) {
          apiClient.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'topic': 'team_${updated.teamId}',
              'title': title,
              'body': body,
              'data': {'type': 'info', 'title': title, 'message': body}
            })
          ).catchError((_) => null);
        }
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

      // Enviar notificación push al estudiante y equipo con el comentario completo
      try {
        final String title = isApproved ? 'Propuesta Aprobada' : 'Propuesta Rechazada';
        String body = isApproved 
            ? '¡Felicidades! Tu propuesta ha sido APROBADA.' 
            : 'Tu propuesta de proyecto ha sido RECHAZADA.';

        if (comment.trim().isNotEmpty) {
          body += isApproved 
              ? '\nComentario del docente: ${comment.trim()}' 
              : '\nMotivo: ${comment.trim()}';
        }

        final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/topic/push');

        // Push directo al estudiante / creador
        apiClient.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'topic': 'user_${updated.studentId}',
            'title': title,
            'body': body,
            'data': {'type': 'info', 'title': title, 'message': body}
          })
        ).catchError((_) => null);

        // Push directo al equipo completo
        if (updated.teamId.isNotEmpty) {
          apiClient.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'topic': 'team_${updated.teamId}',
              'title': title,
              'body': body,
              'data': {'type': 'info', 'title': title, 'message': body}
            })
          ).catchError((_) => null);
        }
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
