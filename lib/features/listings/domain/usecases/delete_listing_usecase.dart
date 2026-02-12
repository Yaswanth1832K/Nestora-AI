import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/listing_repository.dart';

class DeleteListingUseCase {
  final ListingRepository _repository;

  const DeleteListingUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteListing(id);
  }
}
