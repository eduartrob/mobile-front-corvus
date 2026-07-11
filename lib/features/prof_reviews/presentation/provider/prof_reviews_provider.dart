import 'package:flutter/foundation.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/prof_reviews/data/models/final_review_model.dart';
import 'package:mobile/features/prof_reviews/data/prof_reviews_remote_data_source.dart';

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
