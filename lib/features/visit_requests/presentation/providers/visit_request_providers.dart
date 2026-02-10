import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:house_rental/features/visit_requests/data/datasources/visit_request_remote_datasource.dart';
import 'package:house_rental/features/visit_requests/data/repositories/visit_request_repository_impl.dart';
import 'package:house_rental/features/visit_requests/domain/entities/visit_request_entity.dart';
import 'package:house_rental/features/visit_requests/domain/repositories/visit_request_repository.dart';

final visitRequestRemoteDataSourceProvider = Provider<VisitRequestRemoteDataSource>((ref) {
  return VisitRequestRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final visitRequestRepositoryProvider = Provider<VisitRequestRepository>((ref) {
  return VisitRequestRepositoryImpl(ref.watch(visitRequestRemoteDataSourceProvider));
});

final ownerVisitRequestsProvider = StreamProvider.family<List<VisitRequestEntity>, String>((ref, ownerId) {
  return ref.watch(visitRequestRepositoryProvider).getOwnerVisitRequests(ownerId);
});

final createVisitRequestUseCaseProvider = Provider((ref) {
  return (VisitRequestEntity request) => ref.watch(visitRequestRepositoryProvider).createVisitRequest(request);
});

final updateVisitStatusUseCaseProvider = Provider((ref) {
  return (String requestId, String status) => ref.watch(visitRequestRepositoryProvider).updateVisitRequestStatus(requestId, status);
});
