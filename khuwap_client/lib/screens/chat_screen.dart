import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String userId;
  final String postUUID;
  final String peerId;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.userId,
    required this.postUUID,
    required this.peerId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<ChatProvider>();


      // 글 상태 로딩
      await provider.loadPostStatus(widget.postUUID);

      // 지난 메시지 로딩
      await provider.loadMessages(widget.roomId);

      // WebSocket 연결
      provider.connectChat(
        userId: widget.userId,
        postUUID: widget.postUUID,
        peerId: widget.peerId,
      );

      // 메시지 로딩 후 스크롤 맨 아래
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().disposeChat();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    // 새 메시지 들어오면 스크롤 자동 이동
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Text("채팅"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final msg = chat.messages[index];
                final isMine = msg.senderId == widget.userId;

                return Align(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.blue[300] : Colors.grey[300],
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

  Widget _inputField(ChatProvider chat, {bool disabled = false}) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !disabled,
              decoration: InputDecoration(
              hintText: disabled ? "완료된 교환입니다" : "메시지 입력...",
            ),
            ),            
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.trim().isEmpty) return;

              chat.send(_controller.text.trim());
              _controller.clear();
              _scrollToBottom();
            },
          )
        ],
      ),
    );
  }
}