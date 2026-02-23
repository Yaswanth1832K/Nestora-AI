import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:house_rental/features/reviews/data/models/review_model.dart';
import 'package:house_rental/features/reviews/domain/entities/review_entity.dart';
import 'package:house_rental/features/reviews/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, void>> addReview(ReviewEntity review) async {
    try {
      final model = ReviewModel.fromEntity(review);
      
      // Use a batch to update average rating in the future? 
      // For now, simple set.
      await _firestore.collection('reviews').doc(model.id).set(model.toFirestore());
      
      // Update listing review count and average rating (simplified)
      final listingDoc = _firestore.collection('listings').doc(review.listingId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(listingDoc);
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final int count = data['reviewCount'] ?? 0;
          final double avg = (data['averageRating'] ?? 0.0).toDouble();
          
          final newCount = count + 1;
          final newAvg = ((avg * count) + review.rating) / newCount;
          
          transaction.update(listingDoc, {
            'reviewCount': newCount,
            'averageRating': newAvg,
          });
        }
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ReviewEntity>> getReviewsForListing(String listingId) {
    return _firestore
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }
}
