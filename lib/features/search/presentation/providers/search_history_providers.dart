import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Should be overridden in ProviderScope
});

final searchHistoryProvider = AsyncNotifierProvider<SearchHistoryNotifier, List<String>>(() {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'search_history';

  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> addQuery(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    final currentHistory = state.value ?? [];
    
    // Remove if already exists (to move to top)
    final newHistory = [
      trimmedQuery,
      ...currentHistory.where((q) => q.toLowerCase() != trimmedQuery.toLowerCase()),
    ].take(5).toList();

    state = AsyncValue.data(newHistory);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newHistory);
  }

  Future<void> clearHistory() async {
    state = const AsyncValue.data([]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
