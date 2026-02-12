import 'package:house_rental/features/chat/domain/entities/message_entity.dart';
import 'package:house_rental/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesStreamUseCase {
  final ChatRepository _repository;

  GetMessagesStreamUseCase(this._repository);

  Stream<List<MessageEntity>> call(String chatRoomId) {
    return _repository.getMessagesStream(chatRoomId);
  }
}
