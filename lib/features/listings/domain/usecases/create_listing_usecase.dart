import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class CreateListingUseCase {
  final ListingRepository _repository;

  const CreateListingUseCase(this._repository);

  Future<Either<Failure, void>> call(ListingEntity listing) {
    return _repository.createListing(listing);
  }
}
