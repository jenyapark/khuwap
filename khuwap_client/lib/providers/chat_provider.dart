import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message_item.dart';
import '../services/chat_ws_service.dart';

class ChatRoom {
  final String roomId;
  final String postUUID;
  final String peerId;
  String lastMessage;

  ChatRoom({
    required this.roomId,
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
  String? currentPostStatus;

  Future<void> loadPostStatus(String postUUID) async {
  final url = Uri.parse("http://localhost:8000/exchange/$postUUID");

  final res = await http.get(url);
  if (res.statusCode != 200) {
    print("Failed to load post status");
    return;
  }

  final data = jsonDecode(res.body);
  currentPostStatus = data["data"]["status"];

  notifyListeners();
}

bool get isCompleted => currentPostStatus == "completed";

  Future<void> loadRooms(String userId) async {
    final url = Uri.parse("http://localhost:8000/chat/rooms?user_id=$userId");

    final res = await http.get(url);

    if (res.statusCode != 200) {
      print("Failed to load rooms: ${res.body}");
      return;
    }

    final data = jsonDecode(res.body);

    final List<dynamic> list = data["data"];

    rooms.clear();

    for (var item in list) {
      rooms.add(
        ChatRoom(
          roomId: item["room_id"],
          postUUID: item["post_uuid"],
          peerId: item["peer_id"],
          lastMessage: item["last_message"] ?? "",
        ),
      );
    }

    notifyListeners();
  }

  // 지난 메시지 로딩

  Future<void> loadMessages(String roomId) async {
    final url = Uri.parse("http://localhost:8000/chat/messages?room_id=$roomId");

    final res = await http.get(url);
    if (res.statusCode != 200) {
      print("Failed to load messages: ${res.body}");
      return;
    }

    final data = jsonDecode(res.body);
    final List<dynamic> list = data["data"];

    messages.clear();

    for (var item in list) {
      messages.add(
        ChatMessageItem(
          senderId: item["sender_id"],
          content: item["content"],
          createdAt: DateTime.parse(item["created_at"]),
        ),
      );
    }

    notifyListeners();
  }




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
      rooms.add(
        ChatRoom(
          roomId: "unknown", //서버에서 loadRooms() 호출 후 대체됨
          postUUID: postUUID,
          peerId: peerId,
        ),
      );
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
