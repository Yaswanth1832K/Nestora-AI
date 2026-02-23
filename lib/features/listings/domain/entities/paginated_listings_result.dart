import 'package:house_rental/features/listings/domain/entities/listing_entity.dart';

/// Result of a paginated listings query. [nextCursor] is the last document id
/// to pass to the next page; null when no more pages.
class PaginatedListingsResult {
  final List<ListingEntity> items;
  final String? nextCursor;

  const PaginatedListingsResult({
    required this.items,
    this.nextCursor,
  });

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
