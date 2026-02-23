import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:house_rental/features/reviews/domain/repositories/review_repository.dart';
import 'package:house_rental/features/reviews/domain/usecases/add_review_usecase.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(FirebaseFirestore.instance);
});

final addReviewUseCaseProvider = Provider<AddReviewUseCase>((ref) {
  return AddReviewUseCase(ref.watch(reviewRepositoryProvider));
});

final listingReviewsProvider = StreamProvider.family<List, String>((ref, listingId) {
  return ref.watch(reviewRepositoryProvider).getReviewsForListing(listingId);
});
