import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:house_rental/main.dart';
import 'package:house_rental/features/listings/presentation/pages/listing_details_page.dart';
import 'package:house_rental/core/router/app_router.dart';
import 'package:house_rental/features/listings/domain/entities/listing_entity.dart';
import 'package:house_rental/features/listings/presentation/providers/favorites_notifier.dart';
import 'package:house_rental/features/auth/presentation/providers/auth_providers.dart';

class ListingCard extends ConsumerWidget {
  final ListingEntity listing;
  
  const ListingCard({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesNotifierProvider);
    final isFavorite = favorites.value?.contains(listing.id) ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          rootNavigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (_) => ListingDetailsPage(listing: listing),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 140,
                    child: listing.allImages.isNotEmpty
                        ? Image.network(
                            listing.allImages.first,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                debugPrint('Image loaded for listing ${listing.id}: ${listing.allImages.first}');
                                return child;
                              }
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  color: Colors.white,
                                  width: double.infinity,
                                  height: 140,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading image for listing ${listing.id}: $error\nURL: ${listing.allImages.first}');
                              return Container(
                                color: Colors.blue.shade50,
                                child: const Icon(Icons.broken_image, size: 50, color: Colors.blue),
                              );
                            },
                          )
                        : Container(
                            color: Colors.blue.shade50,
                            child: const Icon(Icons.home, size: 50, color: Colors.blue),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      iconSize: 24,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey.shade600,
                      ),
                      onPressed: () {
                        debugPrint('ListingCard: Favorite button pressed for ${listing.id}');
                        final authState = ref.read(authStateProvider);
                        final user = authState.value;
                        
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please log in to save favorites')),
                          );
                          return;
                        }
                        
                        ref.read(favoritesNotifierProvider.notifier).toggleFavorite(listing.id).then((result) {
                          result.fold(
                            (failure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to save to cloud: ${failure.message}')),
                              );
                            },
                            (_) => null,
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${listing.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        listing.city,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Spacer(),
                      if (listing.reviewCount > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              listing.averageRating.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ' (${listing.reviewCount})',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${listing.bedrooms} Beds • ${listing.bathrooms} Baths • ${listing.sqft.toStringAsFixed(0)} sqft',
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
