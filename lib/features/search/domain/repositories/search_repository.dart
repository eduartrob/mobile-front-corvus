import 'package:mobile/features/search/domain/entities/smart_search_result.dart';

abstract class SearchRepository {
  Future<SmartSearchResult> searchSmart(String query);
}
