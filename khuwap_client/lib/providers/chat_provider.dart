import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message_item.dart';
import '../models/chat_room_item.dart';
import '../services/chat_ws_service.dart';
import '../services/exchange_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatProvider extends ChangeNotifier {
  final ChatWebSocketService _ws = ChatWebSocketService();
  final List<ChatMessageItem> messages = [];
  List<ChatRoomItem> rooms = [];

  String? userId;
  String? postUUID;
  String? peerId;
  String? currentPostStatus;
  String? openedRoomId;
  WebSocketChannel? _wsChannel;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

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
      final String authorId = item["author_id"];
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
        "ROOM DEBUG → roomId=${room.roomId}, post=${room.postUUID}, peer=${room.peerId}, unread=${room.unreadCount}, last=${room.lastMessage}",
      );

      // 게시글 메타 정보 로딩
      final postRaw = await ExchangeService.fetchPostRaw(room.postUUID);

      if (postRaw != null) {
        final String currentCode = postRaw["current_course"];
        final String desiredCode = postRaw["desired_course"];

        final owned = await ExchangeService.fetchCourseDetail(currentCode);
        final desired = await ExchangeService.fetchCourseDetail(desiredCode);

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
    notifyListeners();
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
    try {
      final url = Uri.parse(
        "http://localhost:8000/chat/messages?room_id=$roomId&user_id=$userId",
      );

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
    } catch (e) {
      print(">>> [ChatProvider] Message Parsing Error: $e");
    }
  }

  void connectChat({
    required String userId,
    required String postUUID,
    required String peerId,
  }) {
    this.userId = userId;
    this.postUUID = postUUID;
    this.peerId = peerId;

    if (_isConnected) {
      print("WS already connected. Skipping connection attempt.");
      return;
    }

    _ws.connect(userId: userId, onMessage: _handleMessage);
  }

  void _handleMessage(Map<String, dynamic> data) {
    final String sender = data["sender_id"];
    final String receivedRoomId = data["room_id"];

    if (userId == null) {
      print("WARNING: Message received before userId was initialized.");
      return;
    }

    final newMessage = ChatMessageItem(
      senderId: sender,
      content: data["content"],
      createdAt: DateTime.now(),
    );

    if (receivedRoomId == openedRoomId) {
      // 현재 채팅 화면에 메시지 추가 및 갱신
      messages.add(newMessage);
    }

    ChatRoomItem? targetRoom;
    for (final room in rooms) {
      if (room.roomId == receivedRoomId) {
        targetRoom = room;
        break;
      }
    }

    if (targetRoom != null) {
      print("MATCHED ROOM: ${targetRoom.roomId}");
      targetRoom.lastMessage = data["content"];
      if (receivedRoomId != openedRoomId) {
        targetRoom.unreadCount++;
      }
      rooms = List.from(rooms);
    }
    notifyListeners();
  }

  void send(String text) {
    if (userId == null || openedRoomId == null) {
      print(
        ">>> [ChatProvider.send] ERROR: userId or openedRoomId is null. Aborting.",
      );
      return;
    }
    ChatRoomItem? currentRoom;
    try {
      currentRoom = rooms.firstWhere((room) => room.roomId == openedRoomId);
    } catch (e) {
      print(
        ">>> [ChatProvider.send] ERROR: Room ID $openedRoomId not found in rooms list. Aborting message send.",
      );
      return;
    }

    _ws.sendMessage(
      senderId: userId!,
      postUUID: currentRoom.postUUID,
      roomId: currentRoom.roomId,
      peerId: currentRoom.peerId,
      content: text,
    );
  }

  void disposeChat() {
    if (_wsChannel != null) {
      _wsChannel!.sink.close();
      _wsChannel = null;
      _isConnected = false;
      print("WS disconnected manually.");
    }
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

  Future<String> createChatRoom({
    required String postUUID,
    required String authorId,
    required String peerId,
  }) async {
    const String baseUrl = "http://localhost:8000";
    final Map<String, dynamic> body = {
      "post_uuid": postUUID,
      "author_id": authorId, // 일반적으로 게시글 작성자
      "peer_id": peerId, // 일반적으로 요청을 보내는 사용자
    };
    final uri = Uri.parse('$baseUrl/chat/room/create').replace(
      queryParameters: {
        'post_uuid': postUUID,
        'author_id': authorId,
        'peer_id': peerId,
      },
    );

    try {
      // 3. API 호출
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      // 4. 응답 처리
      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));

        // 5. 'room_id' 추출 및 반환
        final String roomId = responseData['room_id'] as String;
        print(">>> Chat Room created successfully. Room ID: $roomId");
        return roomId;
      } else {
        // 200 OK가 아닌 경우 (404, 500 등)
        final errorBody = utf8.decode(response.bodyBytes);
        print(
          ">>> Chat Room creation failed. Status: ${response.statusCode}, Body: $errorBody",
        );
        throw Exception("Failed to create chat room: ${response.statusCode}");
      }
    } catch (e) {
      print(">>> API connection error during room creation: $e");
      throw Exception("Network or processing error: $e");
    }
  }
}
