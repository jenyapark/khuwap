import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message_item.dart';
import '../models/chat_room_item.dart';
import '../services/chat_ws_service.dart';
import '../services/exchange_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatWebSocketService _ws = ChatWebSocketService();
  final List<ChatMessageItem> messages = [];
  List<ChatRoomItem> rooms = [];

  String? userId;
  String? postUUID;
  String? peerId;
  String? currentPostStatus;
  String? openedRoomId;

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
    final String authorId   = item["author_id"];
    final String peerFromApi = item["peer_id"];

    // 현재 로그인한 나 기준으로 상대방 아이디 결정
    final String peerId = (userId == authorId) ? peerFromApi : authorId;

    final room = ChatRoomItem(
      roomId: item["room_id"],
      postUUID: item["post_uuid"],
      peerIdFromApi: peerFromApi,
      peerId: peerId,
      lastMessage: item["last_message"] ?? "",
      unreadCount: item["unread_count"] ?? 0,     
    );

    print(
        "ROOM DEBUG → roomId=${room.roomId}, post=${room.postUUID}, peer=${room.peerId}, unread=${room.unreadCount}, last=${room.lastMessage}");

    // 게시글 메타 정보 로딩
    final postRaw =
        await ExchangeService.fetchPostRaw(room.postUUID);

    if (postRaw != null) {
      final String currentCode = postRaw["current_course"];
      final String desiredCode = postRaw["desired_course"];

      final owned = await ExchangeService.fetchCourseDetail(currentCode);
      final desired =
          await ExchangeService.fetchCourseDetail(desiredCode);

      if (owned != null && desired != null) {
        final ownedName = owned["course_name"];
        final desiredName = desired["course_name"];

        room.ownedCourseName = ownedName;
        room.desiredCourseName = desiredName;

        room.postTitle = "$ownedName ↔ $desiredName";
      } else {
        room.postTitle = "과목 정보 없음";
      }
    } else {
      room.postTitle = "과목 정보 없음";
    }

    rooms.add(room);
  }

  rooms.sort((a, b) {
    if (b.unreadCount != a.unreadCount) {
      return b.unreadCount.compareTo(a.unreadCount);
    }
    return 0; 
  });

  notifyListeners();
}



  void updateOpenedRoom(String? roomId) {
  openedRoomId = roomId;
}

void resetUnreadCount(String roomId) {
  for (final room in rooms) {
    if (room.roomId == roomId) {
      room.unreadCount = 0;
    }
  }
  notifyListeners();
}



  // 지난 메시지 로딩

  Future<void> loadMessages(String roomId) async {
    if (userId == null) {
    print("userId is null in loadMessages()");
    return;
   }
    final url = Uri.parse("http://localhost:8000/chat/messages?room_id=$roomId&user_id=$userId");

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
          createdAt: DateTime.parse(item["timestamp"]),
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
  }

  
  

void _handleMessage(Map<String, dynamic> data) {
  final String sender = data["sender_id"];
  final String peer   = data["peer_id"];
  final String post   = data["post_uuid"];
  final String? me    = userId;

  messages.add(
    ChatMessageItem(
      senderId: sender,
      content: data["content"],
      createdAt: DateTime.now(),
    ),
  );

  if (me == null) {
    notifyListeners();
    return;
  }

  final String other = (sender == me) ? peer : sender;

  ChatRoomItem? targetRoom;
  for (final room in rooms) {
    if (room.postUUID == post && room.peerId == other) {
      targetRoom = room;
      break;
    }
  }

  if (targetRoom == null) {
    print("⚠ 메시지 도착했지만 해당 방을 찾지 못함. (post=$post, other=$other)");
    notifyListeners();
    return;
  }

  print("MATCHED ROOM: ${targetRoom.roomId}, other=$other");

  // 마지막 메시지 업데이트만 수행
  targetRoom.lastMessage = data["content"];

  // 리스트 업데이트
  rooms = List.from(rooms);
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

  void addOrUpdateRoom(ChatRoomItem room) {
  final idx = rooms.indexWhere((r) => r.roomId == room.roomId);

  if (idx >= 0) {
    rooms[idx] = room; // 업데이트
  } else {
    rooms.add(room); // 새로 추가
  }

  notifyListeners();
}



}
