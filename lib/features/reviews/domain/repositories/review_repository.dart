import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:house_rental/features/reviews/domain/entities/review_entity.dart';

abstract interface class ReviewRepository {
  Future<Either<Failure, void>> addReview(ReviewEntity review);
  Stream<List<ReviewEntity>> getReviewsForListing(String listingId);
}
