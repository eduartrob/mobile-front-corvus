import 'package:mobile/features/search/domain/entities/smart_search_result.dart';
import 'package:mobile/features/search/domain/repositories/search_repository.dart';
import 'package:mobile/features/search/data/data_source/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<SmartSearchResult> searchSmart(String query) async {
    final response = await remoteDataSource.searchSmart(query);
    return SmartSearchResult.fromJson(response);
  }
}
