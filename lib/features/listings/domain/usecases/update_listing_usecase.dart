import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class UpdateListingUseCase {
  final ListingRepository _repository;

  const UpdateListingUseCase(this._repository);

  Future<Either<Failure, void>> call(ListingEntity listing) {
    return _repository.updateListing(listing);
  }
}
