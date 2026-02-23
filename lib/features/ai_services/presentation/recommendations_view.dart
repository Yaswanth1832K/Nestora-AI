import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/listings/domain/entities/listing_entity.dart';
import 'package:house_rental/features/listings/presentation/providers/listings_providers.dart';
import 'package:house_rental/features/home/presentation/widgets/listing_card.dart';
import 'package:house_rental/core/theme/theme_provider.dart';
import 'package:house_rental/features/ai_services/presentation/providers/ai_providers.dart';
import 'package:house_rental/features/auth/presentation/providers/auth_providers.dart';
import 'package:house_rental/core/providers/firebase_provider.dart';

class RecommendationsView extends ConsumerStatefulWidget {
  const RecommendationsView({super.key});

  @override
  ConsumerState<RecommendationsView> createState() => _RecommendationsViewState();
}

class _RecommendationsViewState extends ConsumerState<RecommendationsView> {
  bool _isLoading = true;
  String? _error;
  List<ListingEntity> _recommendedListings = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecommendations();
    });
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final allListingsResult = await ref.read(getListingsUseCaseProvider)();
    
    if (!mounted) return;

    allListingsResult.fold(
      (failure) {
        setState(() {
          _error = 'Failed to load properties for analysis: ${failure.message}';
          _isLoading = false;
        });
      },
      (listings) async {
        if (listings.isEmpty) {
          setState(() {
            _error = 'No properties available to recommend from.';
            _isLoading = false;
          });
          return;
        }

        try {
          // Fetch user preferences from Firestore
          final user = ref.read(authStateProvider).value;
          String userPreferences = "Looking for a good rental property.";
          
          if (user != null) {
            final doc = await ref.read(firestoreProvider).collection('users').doc(user.uid).get();
            if (doc.exists && doc.data()?['rentalPreferences'] != null) {
              final prefs = doc.data()!['rentalPreferences'] as Map<String, dynamic>;
              final budgetMin = prefs['budgetMin'] ?? 500;
              final budgetMax = prefs['budgetMax'] ?? 3000;
              final propertyType = prefs['propertyType'] ?? 'Apartment';
              final location = prefs['location'] ?? 'anywhere';
              final bedrooms = prefs['bedrooms'] ?? 1;
              final amenitiesList = (prefs['amenities'] as Map<String, dynamic>?)
                  ?.entries
                  .where((e) => e.value == true)
                  .map((e) => e.key)
                  .toList() ?? [];
              
              userPreferences = "I am looking for a $propertyType in $location. "
                  "My budget is between \$$budgetMin and \$$budgetMax. "
                  "I need at least $bedrooms bedrooms. "
                  "Preferred amenities: ${amenitiesList.isEmpty ? 'none specific' : amenitiesList.join(', ')}.";
            }
          }
          
          // Map listings to a lean JSON string to send to Gemini
          final String availableProperties = listings.map((l) => 
            '{"id": "${l.id}", "title": "${l.title}", "city": "${l.city}", "price": ${l.price}, "bedrooms": ${l.bedrooms}, "amenities": "${l.amenities.join(', ')}"}'
          ).toList().join(', ');

          final result = await ref.read(getRecommendationsUseCaseProvider)({
            'preferences': userPreferences,
            'properties': '[$availableProperties]'
          });

          if (!mounted) return;

          result.fold(
            (failure) {
              setState(() {
                _error = 'AI Analysis failed: ${failure.message}';
                _isLoading = false;
              });
            },
            (aiResponse) {
              // Parse AI response to find matching IDs and build the recommended list
              // (In a production app, the AI would return strict JSON, but we parse text here)
              final recommended = listings.where((listing) {
                // simple substring check if the AI mentioned the ID
                return aiResponse.contains(listing.id);
              }).toList();

              setState(() {
                _recommendedListings = recommended.isNotEmpty ? recommended : listings.take(3).toList();
                _isLoading = false;
              });
            },
          );
        } catch (e) {
             setState(() {
                _error = 'An unexpected error occurred: $e';
                _isLoading = false;
              });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(height: 16),
            Text("AI is analyzing thousands of properties for you..."),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchRecommendations,
                child: const Text('Try Again'),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 8),
            Text('AI Recommendations'),
          ],
        ),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade900, Colors.deepPurple.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.insights, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Based on your profile, we think these properties are perfect for you.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recommendedListings.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ListingCard(listing: _recommendedListings[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
