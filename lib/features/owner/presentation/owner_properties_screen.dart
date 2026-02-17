import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:house_rental/features/auth/presentation/providers/auth_providers.dart';
import 'package:house_rental/features/home/presentation/widgets/listing_card.dart';
import 'package:house_rental/features/listings/domain/entities/listing_entity.dart';
import 'package:house_rental/features/listings/data/models/listing_model.dart';
import 'package:house_rental/features/listings/presentation/providers/listings_providers.dart';
import 'package:house_rental/core/theme/theme_provider.dart';

class OwnerPropertiesScreen extends ConsumerStatefulWidget {
  const OwnerPropertiesScreen({super.key});

  @override
  ConsumerState<OwnerPropertiesScreen> createState() => _OwnerPropertiesScreenState();
}

class _OwnerPropertiesScreenState extends ConsumerState<OwnerPropertiesScreen> {
  
  Future<void> _deleteListing(String listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: const Text('Are you sure you want to delete this property? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(deleteListingUseCaseProvider)(listingId);
    
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: ${failure.message}')),
          );
        }
      },
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property deleted successfully')),
          );
        }
      },
    );
  }

  Future<void> _updateStatus(ListingEntity listing, String newStatus) async {
    final updatedListing = listing.copyWith(status: newStatus, updatedAt: DateTime.now());
    final result = await ref.read(updateListingUseCaseProvider)(updatedListing);
    
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${failure.message}')),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property marked as ${newStatus == ListingEntity.statusRented ? 'Rented' : 'Available'}')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    if (user == null) {
        return Scaffold(
            body: Center(child: Text("Please login to view your properties", style: TextStyle(color: isDark ? Colors.white : Colors.black))),
        );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("My Properties", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        actions: [
             IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 28),
                tooltip: 'Post New Property',
                onPressed: () => context.push(AppRouter.postProperty),
            ),
             const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.postProperty),
        icon: const Icon(Icons.add),
        label: const Text("Add Property"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('listings')
            .where('ownerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          final docs = snapshot.data!.docs;

          final listings = docs.map((doc) => ListingModel.fromFirestore(doc)).toList();

          final total = listings.length;
          final available = listings.where((l) => l.status == ListingEntity.statusAvailable || l.status == 'active').length;
          final rented = listings.where((l) => l.status == ListingEntity.statusRented).length;

          return Column(
            children: [
              _buildDashboard(total, available, rented, isDark),
              Expanded(
                child: listings.isEmpty 
                ? _buildEmptyState(isDark)
                : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100, top: 8),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return _buildListingItem(listing, isDark);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboard(int total, int available, int rented, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
            : [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Total", total.toString(), null, Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem("Available", available.toString(), Icons.check_circle, Colors.greenAccent),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem("Rented", rented.toString(), Icons.vpn_key, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData? icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, color: color, size: 16), const SizedBox(width: 4)],
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 60, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "No properties listed yet",
            style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildListingItem(ListingEntity listing, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListingCard(
        listing: listing,
        showFavoriteButton: false,
        margin: EdgeInsets.zero,
        isVerticalFeed: true,
        onTap: () {
          context.push(
            AppRouter.propertyRequests,
            extra: {
              'listingId': listing.id,
              'title': listing.title,
            },
          );
        },
        actionButton: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(8),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteListing(listing.id);
              } else if (value == 'edit') {
                context.push(
                  AppRouter.postProperty,
                  extra: listing,
                );
              } else if (value == 'mark_rented') {
                _updateStatus(listing, ListingEntity.statusRented);
              } else if (value == 'mark_available') {
                _updateStatus(listing, ListingEntity.statusAvailable);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Details'),
                  ],
                ),
              ),
              if (listing.status != ListingEntity.statusRented)
                const PopupMenuItem<String>(
                  value: 'mark_rented',
                  child: Row(
                    children: [
                      Icon(Icons.key_off, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text('Mark as Rented'),
                    ],
                  ),
                ),
              if (listing.status == ListingEntity.statusRented)
                const PopupMenuItem<String>(
                  value: 'mark_available',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('Mark as Available'),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Listing'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
