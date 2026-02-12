import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavoriteUseCase {
  final FavoritesRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required String userId,
    required String listingId,
  }) async {
    return await _repository.toggleFavorite(userId, listingId);
  }
}
