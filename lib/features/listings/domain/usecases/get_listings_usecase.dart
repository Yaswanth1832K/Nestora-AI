import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class GetListingsUseCase {
  final ListingRepository _repository;

  const GetListingsUseCase(this._repository);

  Future<Either<Failure, List<ListingEntity>>> call({
    ListingFilter? filter,
    int limit = 10,
    String? lastListingId,
  }) {
    return _repository.getListings(
      filter: filter,
      limit: limit,
      lastListingId: lastListingId,
    );
  }
}
