import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;

  void connect({
    required String userId,
    required String postUUID,
    required String peerId,
    required void Function(Map<String, dynamic>) onMessage,
  }) {

    final wsUrl = Uri(
      scheme: "ws",
      host: "localhost", // ← 네 PC 로컬 IP 직접 넣기
      port: 8080,
      path: "/ws",
      queryParameters: {
        "user_id": userId,
        "post_uuid": postUUID,
        "peer_id": peerId,
      },
    );

    print("WS CONNECT URI => $wsUrl");

    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (event) {
        if (event is String && event.trim().startsWith("{")) {
          try {
            final data = jsonDecode(event);
            if (data is Map<String, dynamic>) {
              onMessage(data);
            }
          } catch (e) {
            print("WS JSON decode error: $e");
          }
        } else {
          print("WS non-JSON: $event");
        }
      },
      onError: (err) {
        print("WS error: $err");
      },
      onDone: () {
        print("WS closed");
      },
    );
  }

  void sendMessage({
    required String senderId,
    required String postUUID,
    required String peerId,
    required String content,
  }) {
    final msg = {
      "sender_id": senderId,
      "post_uuid": postUUID,
      "peer_id": peerId,
      "content": content,
    };
    _channel?.sink.add(jsonEncode(msg));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}

