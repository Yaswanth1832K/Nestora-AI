/// Firestore collection and field name constants.
abstract final class FirestoreConstants {
  FirestoreConstants._();

  // Collections
  static const String users = 'users';
  static const String listings = 'listings';
  static const String userActivity = 'user_activity';
  static const String marketStats = 'market_stats';
  static const String priceHistory = 'price_history';

  // Subcollections
  static const String favorites = 'favorites';
  static const String viewHistory = 'view_history';
}
