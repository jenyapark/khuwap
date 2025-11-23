import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String userId;

  const ChatListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("메시지 목록"),
      ),
      body: ListView.builder(
        itemCount: chat.rooms.length,
        itemBuilder: (context, index) {
          final room = chat.rooms[index];

          return ListTile(
            title: Text("교환글: ${room.postUUID}"),
            subtitle: Text(room.lastMessage.isEmpty ? "메시지 없음" : room.lastMessage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    userId: userId,
                    postUUID: room.postUUID,
                    peerId: room.peerId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
