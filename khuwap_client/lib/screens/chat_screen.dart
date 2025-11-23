import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String postUUID;
  final String peerId;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.postUUID,
    required this.peerId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ChatProvider>().connectChat(
            userId: widget.userId,
            postUUID: widget.postUUID,
            peerId: widget.peerId,
          );
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().disposeChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("채팅"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final msg = chat.messages[index];
                final isMine = msg.senderId == widget.userId;

                return Align(
                  alignment: isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMine
                          ? Colors.blue[300]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.content),
                  ),
                );
              },
            ),
          ),
          _inputField(chat),
        ],
      ),
    );
  }

  Widget _inputField(ChatProvider chat) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(hintText: "메시지 입력..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.trim().isEmpty) return;

              chat.send(_controller.text.trim());
              _controller.clear();
            },
          )
        ],
      ),
    );
  }
}
