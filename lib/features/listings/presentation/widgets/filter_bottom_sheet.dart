import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/listings/domain/repositories/listing_repository.dart';
import 'package:house_rental/features/listings/presentation/providers/listings_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late RangeValues _priceRange;
  int? _bedrooms;
  int? _bathrooms;
  String? _furnishing;
  final List<String> _selectedAmenities = [];

  final List<String> _furnishingOptions = ['Furnished', 'Semi-furnished', 'Unfurnished'];
  final List<String> _amenityOptions = ['Parking', 'WiFi', 'AC', 'Gym', 'Pool'];

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(searchFilterProvider);
    _priceRange = RangeValues(
      currentFilter.minPrice ?? 0,
      currentFilter.maxPrice ?? 100000,
    );
    _bedrooms = currentFilter.bedrooms;
    _bathrooms = currentFilter.bathrooms;
    _furnishing = currentFilter.furnishing;
    if (currentFilter.amenities != null) {
      _selectedAmenities.addAll(currentFilter.amenities!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(searchFilterProvider.notifier).state = ListingFilter();
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          
          // Price Range
          Text(
            'Price Range (₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 200000,
            divisions: 20,
            labels: RangeLabels(
              '₹${_priceRange.start.round()}',
              '₹${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() => _priceRange = values);
            },
          ),

          const SizedBox(height: 16),

          // Bedrooms & Bathrooms
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bedrooms', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: _bedrooms,
                      hint: const Text('Any'),
                      items: [1, 2, 3, 4].map((e) => DropdownMenuItem(
                        value: e,
                        child: Text('$e BHK'),
                      )).toList(),
                      onChanged: (v) => setState(() => _bedrooms = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bathrooms', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: _bathrooms,
                      hint: const Text('Any'),
                      items: [1, 2, 3].map((e) => DropdownMenuItem(
                        value: e,
                        child: Text('$e Bath'),
                      )).toList(),
                      onChanged: (v) => setState(() => _bathrooms = v),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Furnishing
          const Text('Furnishing', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _furnishingOptions.map((e) => ChoiceChip(
              label: Text(e),
              selected: _furnishing == e,
              onSelected: (selected) {
                setState(() => _furnishing = selected ? e : null);
              },
            )).toList(),
          ),

          const SizedBox(height: 16),

          // Amenities
          const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _amenityOptions.map((e) => FilterChip(
              label: Text(e),
              selected: _selectedAmenities.contains(e),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedAmenities.add(e);
                  } else {
                    _selectedAmenities.remove(e);
                  }
                });
              },
            )).toList(),
          ),

          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final filter = ListingFilter(
                  minPrice: _priceRange.start,
                  maxPrice: _priceRange.end,
                  bedrooms: _bedrooms,
                  bathrooms: _bathrooms,
                  furnishing: _furnishing,
                  amenities: _selectedAmenities.isEmpty ? null : _selectedAmenities,
                );
                ref.read(searchFilterProvider.notifier).state = filter;
                Navigator.pop(context);
              },
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
