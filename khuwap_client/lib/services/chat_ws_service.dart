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
    final url =
        "ws://localhost:8080/ws?user_id=$userId&post_uuid=$postUUID&peer_id=$peerId";

    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
      (event) {
        try {
          final data = jsonDecode(event);
          if (data is Map<String, dynamic>) {
            onMessage(data);
          } else {
            print("Invalid WS format: not a map");
          }
        } catch (e) {
          print("WS message decode error: $e");
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
