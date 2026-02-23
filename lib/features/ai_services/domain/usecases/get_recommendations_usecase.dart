import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:house_rental/features/ai_services/data/datasources/ai_remote_datasource.dart';

class GetRecommendationsUseCase {
  final AIRemoteDataSource _aiRemoteDataSource;

  GetRecommendationsUseCase(this._aiRemoteDataSource);

  Future<Either<Failure, String>> call(Map<String, dynamic> data) async {
    try {
      final recommendations = await _aiRemoteDataSource.getRecommendations(data);
      return Right(recommendations);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
