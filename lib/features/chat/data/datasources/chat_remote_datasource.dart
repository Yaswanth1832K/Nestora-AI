import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_rental/features/chat/data/models/chat_room_model.dart';
import 'package:house_rental/features/chat/data/models/message_model.dart';
import 'package:uuid/uuid.dart';

abstract interface class ChatRemoteDataSource {
  Future<ChatRoomModel> createOrGetChat({
    required String listingId,
    required String ownerId,
    required String currentUserId,
  });

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
  });

  Stream<List<MessageModel>> streamMessages(String chatId);

  Stream<List<ChatRoomModel>> userChatRoomsStream(String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSourceImpl(this._firestore);

  @override
  Future<ChatRoomModel> createOrGetChat({
    required String listingId,
    required String ownerId,
    required String currentUserId,
  }) async {
    // Check if chat room already exists
    final query = await _firestore
        .collection('chats')
        .where('listingId', isEqualTo: listingId)
        .where('participants', arrayContains: currentUserId)
        .get();

    // Filter locally for the owner since array-contains only handles one side
    final existingChat = query.docs.where((doc) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      return participants.contains(ownerId);
    });

    if (existingChat.isNotEmpty) {
      return ChatRoomModel.fromFirestore(existingChat.first);
    }

    // Create new chat room
    final id = const Uuid().v4();
    final chatRoom = ChatRoomModel(
      id: id,
      renterId: currentUserId,
      ownerId: ownerId,
      listingId: listingId,
      participants: [currentUserId, ownerId],
    );

    await _firestore.collection('chats').doc(id).set(chatRoom.toFirestore());
    return chatRoom;
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
  }) async {
    final messageId = const Uuid().v4();
    final now = DateTime.now();

    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      text: text,
      createdAt: now,
    );

    final batch = _firestore.batch();

    // Add message to subcollection
    batch.set(
      _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId),
      message.toFirestore(),
    );

    // Update parent chat room last message info
    batch.update(_firestore.collection('chats').doc(chatId), {
      'lastMessage': text,
      'lastTimestamp': Timestamp.fromDate(now),
    });

    await batch.commit();
  }

  @override
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<ChatRoomModel>> userChatRoomsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatRoomModel.fromFirestore(doc)).toList();
    });
  }
}
