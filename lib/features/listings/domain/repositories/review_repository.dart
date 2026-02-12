import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, void>> addReview(ReviewEntity review);
  Stream<List<ReviewEntity>> getReviews(String listingId);
}
