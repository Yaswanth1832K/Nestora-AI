import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/auth/presentation/providers/auth_providers.dart';
import 'package:house_rental/features/listings/presentation/providers/favorites_providers.dart';
import 'package:house_rental/features/listings/presentation/providers/listings_providers.dart';
import 'package:house_rental/features/listings/domain/entities/listing_entity.dart';

/// Notifier to manage the set of favorite listing IDs.
/// Uses AsyncNotifier to handle asynchronous loading from Firestore.
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    // Automatically watch authState. If user logs in/out, build() re-runs.
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    if (user == null) {
      return {};
    }

    // Fetch initial IDs from Firestore via UseCase
    final result = await ref.read(getFavoriteIdsUseCaseProvider)(user.uid);
    return result.fold(
      (failure) => {},
      (ids) => ids.toSet(),
    );
  }

  /// Toggles the favorite status of a listing.
  /// Implements optimistic updates for a snappy UI.
  Future<Either<Failure, bool>> toggleFavorite(String listingId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      debugPrint('FavoritesNotifier: Toggle failed - User is null');
      return Left(ServerFailure(message: 'User must be logged in'));
    }

    final previousState = state.value ?? {};
    final isFavorite = previousState.contains(listingId);
    
    debugPrint('FavoritesNotifier: Toggling $listingId. Current isFavorite: $isFavorite');

    // 1. Optimistic Update: Update UI immediately
    if (isFavorite) {
      state = AsyncValue.data(previousState.where((id) => id != listingId).toSet());
    } else {
      state = AsyncValue.data({...previousState, listingId}.toSet());
    }

    // 2. Persist to Firestore
    final result = await ref.read(toggleFavoriteUseCaseProvider)(
      userId: user.uid,
      listingId: listingId,
    );

    // 3. Rollback if the network request fails
    return result.fold(
      (failure) {
        debugPrint('FavoritesNotifier: Permanent failure: ${failure.message}');
        state = AsyncValue.data(previousState);
        return Left(failure);
      },
      (isNowFavorite) {
        debugPrint('FavoritesNotifier: Successfully toggled to $isNowFavorite');
        // Success - state is already updated optimistically
        return Right(isNowFavorite);
      },
    );
  }

  /// Helper to check if a specific listing is favorited.
  bool isFavorite(String listingId) {
    return state.value?.contains(listingId) ?? false;
  }
}

/// Provider for the FavoritesNotifier.
final favoritesNotifierProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(() {
  return FavoritesNotifier();
});

final favoriteListingsProvider = FutureProvider<List<ListingEntity>>((ref) async {
  final favoriteIds = ref.watch(favoritesNotifierProvider).value ?? {};
  debugPrint('favoriteListingsProvider: Fetching details for ${favoriteIds.length} IDs: $favoriteIds');
  
  if (favoriteIds.isEmpty) return [];

  final repo = ref.read(listingRepositoryProvider);
  final listings = <ListingEntity>[];

  for (final id in favoriteIds) {
    debugPrint('favoriteListingsProvider: Fetching listing with ID: $id');
    final result = await repo.getListingById(id);
    result.fold(
      (failure) {
        debugPrint('favoriteListingsProvider: Failed to fetch listing $id: ${failure.message}');
      },
      (listing) {
        debugPrint('favoriteListingsProvider: Successfully fetched listing: ${listing.title}');
        listings.add(listing);
      },
    );
  }

  debugPrint('favoriteListingsProvider: Returning ${listings.length} listings');
  return listings;
});
