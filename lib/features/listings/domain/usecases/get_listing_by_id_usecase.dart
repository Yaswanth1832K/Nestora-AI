import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class GetListingByIdUseCase {
  final ListingRepository _repository;

  const GetListingByIdUseCase(this._repository);

  Future<Either<Failure, ListingEntity>> call(String id) {
    return _repository.getListingById(id);
  }
}
