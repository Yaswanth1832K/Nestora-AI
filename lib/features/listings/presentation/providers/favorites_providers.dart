import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/favorites_remote_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/get_favorite_ids_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import 'listings_providers.dart';

// Data Layer
final favoritesRemoteDataSourceProvider = Provider<FavoritesRemoteDataSource>((ref) {
  return FavoritesRemoteDataSourceImpl(ref.read(firestoreProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(ref.read(favoritesRemoteDataSourceProvider));
});

// Use Cases
final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(ref.read(favoritesRepositoryProvider));
});

final getFavoriteIdsUseCaseProvider = Provider<GetFavoriteIdsUseCase>((ref) {
  return GetFavoriteIdsUseCase(ref.read(favoritesRepositoryProvider));
});
