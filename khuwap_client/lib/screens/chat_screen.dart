import 'package:flutter/material.dart';
import 'package:khuwap_client/models/chat_message_item.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String userId;
  final String postUUID;
  final String peerId;
  final String postTitle;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.userId,
    required this.postUUID,
    required this.peerId,
    required this.postTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final ScrollController _scroll;

  late ChatProvider provider; 
  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    provider = context.read<ChatProvider>();  

    WidgetsBinding.instance.addPostFrameCallback((_) async {
        provider.updateOpenedRoom(widget.roomId);
        provider.resetUnreadCount(widget.roomId);

        // 글 상태 로딩
        await provider.loadPostStatus(widget.postUUID);

        // websocket 연결
        if (!provider.isConnected) {
            provider.connectChat(
                userId: widget.userId,
                postUUID: widget.postUUID,
                peerId: widget.peerId,
            );
        }

        // 지난 메시지 로딩
        await provider.loadMessages(widget.roomId);

        _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    //context.read<ChatProvider>().updateOpenedRoom(null);
    print("### ChatScreen DISPOSE CALLED ###");
    super.dispose();
  }

  void _scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    const ivory = Color(0xFFFAF8F3);
    const deepRed = Color(0xFF8B0000);
    const deepBrown = Color(0xFF4A2A25);

    final chat = context.watch<ChatProvider>();
    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        elevation: 0,
        iconTheme: const IconThemeData(color: deepRed),
        title: Text(
          widget.postTitle,
          style: TextStyle(
            color: deepRed,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          Selector<ChatProvider, List<ChatMessageItem>>(
            // Selector: ChatProvider에서 messages 리스트만 선택하여 구독
            selector: (context, provider) => provider.messages,
            
            // messages가 변경될 때만 이 builder가 실행됩니다.
            builder: (context, messages, child) {
          return Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final msg = chat.messages[index];
                final isMine = msg.senderId == widget.userId;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment:
                        isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상대방 프로필 동그라미
                      if (!isMine)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: deepRed.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 20, color: deepRed),
                        ),

                      if (!isMine) const SizedBox(width: 8),

                      // 메시지 버블
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isMine
                                ? deepRed.withOpacity(0.12)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: isMine
                                ? null
                                : Border.all(
                                    color: deepRed.withOpacity(0.2),
                                    width: 1,
                                  ),
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: deepBrown,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),

                      if (isMine) const SizedBox(width: 8),

                      // 내 프로필 (오른쪽)
                      if (isMine)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: deepRed.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 20, color: deepRed),
                        ),
                    ],
                  ),
                );
              },
            )
          );
            }
          ),
            

          _inputField(chat),
        ],
      ),
    );
  }

  Widget _inputField(ChatProvider chat) {
  const deepRed = Color(0xFF8B0000);
  const ivory = Color(0xFFFAF8F3);
  const deepBrown = Color(0xFF4A2A25);

  final disabled = chat.isCompleted;

  return SafeArea(
    child: SizedBox(
      height: 64, 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: ivory,
        child: Row(
          children: [
            // 왼쪽 입력창
            Expanded(
              child: Container(
                height: 44, 
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: deepRed.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _controller,
                  enabled: !disabled,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: disabled ? "완료된 교환입니다" : "메시지 입력...",
                    hintStyle: TextStyle(
                      color: deepBrown.withOpacity(0.45),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 전송 버튼
            SizedBox(
              width: 44,
              height: 44,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: deepRed,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  padding: EdgeInsets.zero,
                  onPressed: disabled
                      ? null
                      : () {
                          final text = _controller.text.trim();
                          if (text.isEmpty) return;
                          chat.send(text);
                          _controller.clear();
                          _scrollToBottom();
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
