import 'package:flutter/material.dart';
import '../models/chat_message_item.dart';
import '../services/chat_ws_service.dart';

class ChatRoom {
  final String postUUID;
  final String peerId;
  String lastMessage;

  ChatRoom({
    required this.postUUID,
    required this.peerId,
    this.lastMessage = "",
  });
}

class ChatProvider extends ChangeNotifier {
  final ChatWebSocketService _ws = ChatWebSocketService();
  final List<ChatMessageItem> messages = [];
  final List<ChatRoom> rooms = [];

  String? userId;
  String? postUUID;
  String? peerId;

  void connectChat({
    required String userId,
    required String postUUID,
    required String peerId,
  }) {
    this.userId = userId;
    this.postUUID = postUUID;
    this.peerId = peerId;

    _ws.connect(
      userId: userId,
      postUUID: postUUID,
      peerId: peerId,
      onMessage: _handleMessage,
    );

    _addRoomIfNotExists(postUUID, peerId);
  }

  void _addRoomIfNotExists(String postUUID, String peerId) {
    final exists = rooms.any(
      (room) => room.postUUID == postUUID && room.peerId == peerId,
    );
    if (!exists) {
      rooms.add(ChatRoom(postUUID: postUUID, peerId: peerId));
      notifyListeners();
    }
  }

  void _handleMessage(Map<String, dynamic> data) {
    messages.add(
      ChatMessageItem(
        senderId: data["sender_id"],
        content: data["content"],
        createdAt: DateTime.now(),
      ));

      // 해당 방의 lastMessage 갱신
    for (final room in rooms) {
      if (room.postUUID == data["post_uuid"] &&
          room.peerId == data["peer_id"]) {
        room.lastMessage = data["content"];
      }
    }
    notifyListeners();
  }

  void send(String text) {
    if (userId == null || postUUID == null || peerId == null) return;

    _ws.sendMessage(
      senderId: userId!,
      postUUID: postUUID!,
      peerId: peerId!,
      content: text,
    );
  }

  void disposeChat() {
    _ws.disconnect();
  }
}
