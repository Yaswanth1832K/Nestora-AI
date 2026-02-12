import 'package:house_rental/features/listings/domain/entities/review_entity.dart';
import 'package:house_rental/features/listings/domain/repositories/review_repository.dart';

class GetReviewsUseCase {
  final ReviewRepository _repository;

  GetReviewsUseCase(this._repository);

  Stream<List<ReviewEntity>> call(String listingId) {
    return _repository.getReviews(listingId);
  }
}
