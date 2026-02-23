import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:house_rental/features/auth/domain/repositories/auth_repository.dart';

class UpdateFcmTokenUseCase {
  final AuthRepository repository;

  UpdateFcmTokenUseCase(this.repository);

  Future<Either<Failure, void>> call(String token) {
    return repository.updateFcmToken(token);
  }
}
