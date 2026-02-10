import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class GetListingsInBoundsUseCase {
  final ListingRepository _repository;

  const GetListingsInBoundsUseCase(this._repository);

  Future<Either<Failure, List<ListingEntity>>> call(
      double minLat, double maxLat, double minLng, double maxLng) {
    return _repository.getListingsInBounds(minLat, maxLat, minLng, maxLng);
  }
}
