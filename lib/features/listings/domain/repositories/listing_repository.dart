import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing_entity.dart';


class ListingFilter {
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final int? bathrooms;
  final String? furnishing;
  final List<String>? amenities;
  final String? propertyType;

  ListingFilter({
    this.city,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.bathrooms,
    this.furnishing,
    this.amenities,
    this.propertyType,
  });
}

abstract interface class ListingRepository {
  /// Get paginated listings with optional filters
  Future<Either<Failure, List<ListingEntity>>> getListings({
    ListingFilter? filter,
    int limit = 10,
    String? lastListingId, // For pagination
  });

  /// Get a single listing by ID
  Future<Either<Failure, ListingEntity>> getListingById(String id);

  /// Create a new listing
  Future<Either<Failure, void>> createListing(ListingEntity listing);

  /// Update an existing listing
  Future<Either<Failure, void>> updateListing(ListingEntity listing);

  /// Delete a listing
  Future<Either<Failure, void>> deleteListing(String id);

  /// Get nearby listings based on similarity (price and bedrooms)
  Future<Either<Failure, List<ListingEntity>>> getNearbyListings(ListingEntity baseListing);

  /// Get listings within geographical bounds
  Future<Either<Failure, List<ListingEntity>>> getListingsInBounds(
      double minLat, double maxLat, double minLng, double maxLng);
}
