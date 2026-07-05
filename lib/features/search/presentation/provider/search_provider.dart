import 'package:flutter/material.dart';
import 'package:mobile/features/search/domain/entities/smart_search_result.dart';
import 'package:mobile/features/search/domain/use_cases/smart_search_usecase.dart';

class SearchProvider extends ChangeNotifier {
  final SmartSearchUseCase _smartSearchUseCase;

  SearchProvider(this._smartSearchUseCase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  SmartSearchResult? _currentResult;
  SmartSearchResult? get currentResult => _currentResult;

  Future<void> performSearch(String query) async {
    _isLoading = true;
    _error = null;
    _currentResult = null;
    notifyListeners();

    try {
      final result = await _smartSearchUseCase(query);
      _currentResult = result;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _currentResult = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
