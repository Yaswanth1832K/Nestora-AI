import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:house_rental/features/reviews/domain/entities/review_entity.dart';
import 'package:house_rental/features/reviews/domain/repositories/review_repository.dart';

class AddReviewUseCase {
  final ReviewRepository repository;

  AddReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(ReviewEntity review) {
    return repository.addReview(review);
  }
}
