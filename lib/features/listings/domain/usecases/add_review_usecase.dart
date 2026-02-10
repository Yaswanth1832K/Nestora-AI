import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:house_rental/features/listings/domain/entities/review_entity.dart';
import 'package:house_rental/features/listings/domain/repositories/review_repository.dart';

class AddReviewUseCase {
  final ReviewRepository _repository;

  AddReviewUseCase(this._repository);

  Future<Either<Failure, void>> call(ReviewEntity review) {
    return _repository.addReview(review);
  }
}
