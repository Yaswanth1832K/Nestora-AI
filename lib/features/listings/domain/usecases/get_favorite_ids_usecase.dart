import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/favorites_repository.dart';

class GetFavoriteIdsUseCase {
  final FavoritesRepository _repository;

  GetFavoriteIdsUseCase(this._repository);

  Future<Either<Failure, List<String>>> call(String userId) async {
    return await _repository.getFavoriteIds(userId);
  }
}
