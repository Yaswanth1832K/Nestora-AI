import 'package:equatable/equatable.dart';

class VisitRequestEntity extends Equatable {
  final String id;
  final String listingId;
  final String listingTitle;
  final String ownerId;
  final String tenantId;
  final String tenantName;
  final DateTime date;
  final String time;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  const VisitRequestEntity({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.ownerId,
    required this.tenantId,
    required this.tenantName,
    required this.date,
    required this.time,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        listingId,
        listingTitle,
        ownerId,
        tenantId,
        tenantName,
        date,
        time,
        status,
        createdAt,
      ];

  VisitRequestEntity copyWith({
    String? status,
  }) {
    return VisitRequestEntity(
      id: id,
      listingId: listingId,
      listingTitle: listingTitle,
      ownerId: ownerId,
      tenantId: tenantId,
      tenantName: tenantName,
      date: date,
      time: time,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
