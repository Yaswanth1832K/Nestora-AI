import 'package:dartz/dartz.dart';
import 'package:house_rental/core/errors/failures.dart';
import 'package:house_rental/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String chatRoomId,
    required String senderId,
    required String text,
  }) {
    return _repository.sendMessage(
      chatRoomId: chatRoomId,
      senderId: senderId,
      text: text,
    );
  }
}
