import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class GetNearbyListingsUseCase {
  final ListingRepository _repository;

  const GetNearbyListingsUseCase(this._repository);

  Future<Either<Failure, List<ListingEntity>>> call(ListingEntity baseListing) {
    return _repository.getNearbyListings(baseListing);
  }
}
