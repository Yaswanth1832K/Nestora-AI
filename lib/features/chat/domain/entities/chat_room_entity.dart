import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final String renterId;
  final String ownerId;
  final String listingId;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastTimestamp;

  const ChatRoomEntity({
    required this.id,
    required this.renterId,
    required this.ownerId,
    required this.listingId,
    required this.participants,
    this.lastMessage,
    this.lastTimestamp,
  });

  @override
  List<Object?> get props => [id, renterId, ownerId, listingId, participants, lastMessage, lastTimestamp];
}
