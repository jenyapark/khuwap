import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/chat_provider.dart';
import 'chat_screen.dart';
import 'dart:convert';
import '../models/chat_room_item.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;

  const ChatListScreen({super.key, required this.userId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _loading = true;
  bool _cleared = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ChatProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
          await provider.loadRooms(widget.userId); 

        if (!mounted) return;
        setState(() {
            _loading = false;
        });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cleared) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatProvider>().updateOpenedRoom(null);
            
           _cleared = true; 
            
            print(">>> LIST SCREEN: openedRoomId cleared (PostFrameCallback)");   // 디버그용
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    const ivory = Color(0xFFFAF8F3);
    const deepRed = Color(0xFF8B0000);
    const deepBrown = Color(0xFF4A2A25);
    print("ChatListScreen Provider hash: ${context.watch<ChatProvider>().hashCode}");


    final chat = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        elevation: 0,
        title: Text(
          "메시지",
          style: TextStyle(
            color: deepBrown,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : chat.rooms.isEmpty
              ? Center(
                  child: Text(
                    "채팅방이 없습니다.",
                    style: TextStyle(color: deepBrown, fontSize: 16),
                  ),
                )
              : Column(
            children: [
              Expanded(
                child:ListView.separated(
                  itemCount: chat.rooms.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: deepBrown.withOpacity(0.15), height: 1),
                  itemBuilder: (context, index) {
                    final room = chat.rooms[index];
                      return SizedBox(
    height: 80, //리스트 아이템 높이를 딱 고정
    child: InkWell(
                      onTap: () async {
  final chat = context.read<ChatProvider>();
  final existingRoomId = room.roomId; 

  // 화면 이동
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        roomId: existingRoomId,
        userId: widget.userId,
        postUUID: room.postUUID,
        peerId: room.peerId,
        postTitle: room.postTitle ?? "채팅",
      ),
    ),
  );
                  },
                  child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              // 프로필 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: deepRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: deepRed, size: 26),
              ),

              const SizedBox(width: 12),

              // 제목 + 마지막 메시지
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.postTitle ?? "과목 정보 없음",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: deepBrown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      room.lastMessage.isEmpty
                          ? "메시지 없음"
                          : room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: deepBrown.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // 안 읽음 배지
              if (room.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: deepRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    room.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  color: deepBrown.withOpacity(0.7))
            ],
          ),
                    )
                      )
                      );
                  }
              ),
    )
            ]
              )
    );
    
  }
}
