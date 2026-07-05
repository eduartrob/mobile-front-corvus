import 'package:mobile/features/search/domain/entities/smart_search_result.dart';
import 'package:mobile/features/search/domain/repositories/search_repository.dart';

class SmartSearchUseCase {
  final SearchRepository repository;

  SmartSearchUseCase(this.repository);

  Future<SmartSearchResult> call(String query) async {
    return await repository.searchSmart(query);
  }
}
