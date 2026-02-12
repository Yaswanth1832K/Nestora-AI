import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:house_rental/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:house_rental/features/chat/domain/entities/chat_room_entity.dart';
import 'package:house_rental/features/chat/domain/entities/message_entity.dart';
import 'package:house_rental/features/chat/domain/repositories/chat_repository.dart';
import 'package:house_rental/features/chat/domain/usecases/get_messages_stream_usecase.dart';
import 'package:house_rental/features/chat/domain/usecases/get_or_create_chat_room_usecase.dart';
import 'package:house_rental/features/chat/domain/usecases/send_message_usecase.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider));
});

final getOrCreateChatRoomUseCaseProvider = Provider<GetOrCreateChatRoomUseCase>((ref) {
  return GetOrCreateChatRoomUseCase(ref.watch(chatRepositoryProvider));
});

final getMessagesStreamUseCaseProvider = Provider<GetMessagesStreamUseCase>((ref) {
  return GetMessagesStreamUseCase(ref.watch(chatRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

final messagesStreamProvider = StreamProvider.family<List<MessageEntity>, String>((ref, chatRoomId) {
  return ref.watch(getMessagesStreamUseCaseProvider)(chatRoomId);
});

final userChatRoomsProvider = StreamProvider.family<List<ChatRoomEntity>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).getUserChatRooms(userId);
});
