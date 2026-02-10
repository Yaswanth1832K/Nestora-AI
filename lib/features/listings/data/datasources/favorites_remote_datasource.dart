import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';

abstract interface class FavoritesRemoteDataSource {
  Future<bool> toggleFavorite(String userId, String listingId);
  Future<List<String>> getFavoriteIds(String userId);
  Future<bool> isFavorite(String userId, String listingId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final FirebaseFirestore _firestore;

  FavoritesRemoteDataSourceImpl(this._firestore);

  @override
  Future<bool> toggleFavorite(String userId, String listingId) async {
    try {
      final path = 'users/$userId/favorites/$listingId';
      debugPrint('FavoritesRemoteDataSource: Attempting toggle at $path');

      final favoriteDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(listingId);

      final snapshot = await favoriteDoc.get();

      if (snapshot.exists) {
        debugPrint('FavoritesRemoteDataSource: Document exists, deleting...');
        await favoriteDoc.delete();
        return false; // Result is NOT favorite
      } else {
        debugPrint('FavoritesRemoteDataSource: Document does not exist, setting...');
        await favoriteDoc.set({
          'listingId': listingId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return true; // Result IS favorite
      }
    } catch (e) {
      debugPrint('FavoritesRemoteDataSource: Error during toggle: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<String>> getFavoriteIds(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> isFavorite(String userId, String listingId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(listingId)
          .get();

      return doc.exists;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
