import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/listings/presentation/providers/favorites_notifier.dart';
import 'package:house_rental/features/listings/presentation/widgets/listing_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteListingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Properties")),
      body: favoritesAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No saved properties yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return ListingCard(listing: listings[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text("Error loading favorites: $err"),
        ),
      ),
    );
  }
}
