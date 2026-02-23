import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/location/commute_service.dart';

final commuteServiceProvider = Provider<CommuteService>((ref) => CommuteService());

/// Fetches commute time from property (lat, lng) to destination. Returns null if destination empty or API fails.
final commuteTimeProvider = FutureProvider.family<String?, ({double lat, double lng, String destination})>((ref, params) async {
  if (params.destination.trim().isEmpty) return null;
  final service = ref.read(commuteServiceProvider);
  return service.getCommuteTime(
    propertyLat: params.lat,
    propertyLng: params.lng,
    destination: params.destination,
  );
});
