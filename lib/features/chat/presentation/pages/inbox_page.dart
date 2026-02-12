import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/auth/presentation/providers/auth_providers.dart';
import 'package:house_rental/features/chat/presentation/providers/chat_providers.dart';
import 'package:house_rental/features/chat/presentation/pages/chat_page.dart';
import 'package:house_rental/main.dart';
import 'package:intl/intl.dart';

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Messages")),
        body: const Center(
          child: Text("Please log in to see your messages"),
        ),
      );
    }

    final chatRoomsAsync = ref.watch(userChatRoomsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        elevation: 0,
      ),
      body: chatRoomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No conversations yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(
                  room.listingId.length > 10 
                    ? "Property Chat" // Fallback if title not in room
                    : room.listingId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: (room.lastMessage?.isNotEmpty ?? false)
                    ? Text(
                        room.lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const Text(
                        "No messages yet",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                trailing: room.lastTimestamp != null
                    ? Text(
                        DateFormat.jm().format(room.lastTimestamp!),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    : null,
                onTap: () {
                  rootNavigatorKey.currentState!.push(
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatRoomId: room.id,
                        title: "Chat", // We could fetch listing title if needed
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
