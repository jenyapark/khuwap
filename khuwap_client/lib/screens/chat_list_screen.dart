import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;

  const ChatListScreen({super.key, required this.userId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    // 화면 진입 시 채팅방 목록 로딩
    Future.microtask(() async {
      await context.read<ChatProvider>().loadRooms(widget.userId);
      setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("메시지 목록"),
      ),

      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : chat.rooms.isEmpty
              ? const Center(child: Text("채팅방이 없습니다."))
              : ListView.builder(
                  itemCount: chat.rooms.length,
                  itemBuilder: (context, index) {
                    final room = chat.rooms[index];

                    return ListTile(
                      title: Text("교환글: ${room.postUUID}"),
                      subtitle: Text(
                        room.lastMessage.isEmpty
                            ? "메시지 없음"
                            : room.lastMessage,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              roomId: room.roomId,
                              userId: widget.userId,
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
