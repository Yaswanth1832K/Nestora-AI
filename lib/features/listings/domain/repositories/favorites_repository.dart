import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract interface class FavoritesRepository {
  /// Toggle a listing as favorite for a specific user
  Future<Either<Failure, bool>> toggleFavorite(String userId, String listingId);

  /// Get all favorite listing IDs for a specific user
  Future<Either<Failure, List<String>>> getFavoriteIds(String userId);

  /// Check if a specific listing is favorited by a user
  Future<Either<Failure, bool>> isFavorite(String userId, String listingId);
}
