import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:house_rental/features/chat/domain/entities/chat_room_entity.dart';
import 'package:house_rental/features/chat/domain/repositories/chat_repository.dart';

class GetOrCreateChatRoomUseCase {
  final ChatRepository _repository;

  GetOrCreateChatRoomUseCase(this._repository);

  Future<Either<Failure, ChatRoomEntity>> call({
    required String renterId,
    required String ownerId,
    required String listingId,
  }) {
    return _repository.getOrCreateChatRoom(
      renterId: renterId,
      ownerId: ownerId,
      listingId: listingId,
    );
  }
}
