import 'package:flutter/material.dart';
import 'package:khuwap_client/screens/chat_screen.dart';
import 'package:khuwap_client/screens/edit_exchange_post_screen.dart';
import '../services/auth_service.dart';
import '../services/exchange_service.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/request_item.dart';

class ExchangeDetailScreen extends StatefulWidget {
  final String ownedTitle;
  final String ownedProfessor;
  final String ownedDay;
  final String ownedStart;
  final String ownedEnd;
  final String ownedCourseCode;
  final String ownedRoom;
  final String ownedCredit;

  final String desiredTitle;
  final String desiredProfessor;
  final String desiredDay;
  final String desiredStart;
  final String desiredEnd;
  final String desiredCourseCode;
  final String desiredRoom;
  final String desiredCredit;

  final String note;
  final String authorId;
  final String postUUID;

  final String? requesterId;   
final String? requestUUID;   
final String? requestStatus; 



  const ExchangeDetailScreen({
    super.key,
    required this.ownedTitle,
    required this.ownedProfessor,
    required this.ownedDay,
    required this.ownedStart,
    required this.ownedEnd,
    required this.ownedCourseCode,
    required this.ownedRoom,
    required this.ownedCredit,
    required this.desiredTitle,
    required this.desiredProfessor,
    required this.desiredDay,
    required this.desiredStart,
    required this.desiredEnd,
    required this.desiredCourseCode,
    required this.desiredRoom,
    required this.desiredCredit,
    required this.note,
    required this.authorId,
    required this.postUUID,
    this.requesterId,     
    this.requestUUID,     
    this.requestStatus,   
  });

  @override
  State<ExchangeDetailScreen> createState() => _ExchangeDetailScreenState();
}

class _ExchangeDetailScreenState extends State<ExchangeDetailScreen> {
  late String currentNote;
String? _requesterId;
String? _requestStatus;
RequestItem? myRequest;
bool loadingReq = true;
String? _requestUUID;
bool _loadedRequestState = false;
String? myId;

@override
void initState() {
  super.initState();
  currentNote = widget.note;

  AuthService.getUserId().then((id) {
    setState(() => myId = id);
    loadRequestState();
  });
}


 
Future<void> loadRequestState() async {
  if (_loadedRequestState) {
    print("loadRequestState 이미 실행됨 → 재실행 막음");
    return;
  }
  _loadedRequestState = true;

  final userId = await AuthService.getUserId();
  if (userId == null) {
    setState(() => loadingReq = false);
    return;
  }
  if (userId == widget.authorId) {
  print("현재 로그인한 유저는 글쓴이 → 요청 목록 조회(list) 호출");

  final requestList =
      await ExchangeService.listRequests(widget.postUUID);
      print("requestUUID:  " + requestList.first.requestUUID);
      print("requesterid:    " + requestList.first.requesterId);
      print(requestList.first.status);
  if (requestList.isNotEmpty) {
    final first = requestList.first;

    setState(() {
      _requestUUID = first.requestUUID; 
          // ← 교환 수락 버튼의 핵심 값
      _requesterId = first.requesterId;
      _requestStatus = first.status;    
      loadingReq = false;
    });
  } else {
    setState(() {
      loadingReq = false;
    });
  }
  return;
  }
}




  @override
  Widget build(BuildContext context) {
    print("DEBUG postUUID=${widget.postUUID}");

    const ivory = Color(0xFFFAF8F3);
    const textBrown = Color(0xFF3E2A25);
    const khured = Color(0xFF8B0000);

    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textBrown, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // ---------------- OWNED CARD ----------------
            _buildSubjectDetailCard(
              label: "owned",
              courseCode: widget.ownedCourseCode,
              title: widget.ownedTitle,
              professor: widget.ownedProfessor,
              day: widget.ownedDay,
              start: widget.ownedStart,
              end: widget.ownedEnd,
              room: widget.ownedRoom,
              credit: widget.ownedCredit,
              isRightAligned: false,
            ),

            const SizedBox(height: 20),

            // ---------------- DESIRED CARD ----------------
            _buildSubjectDetailCard(
              label: "desired",
              courseCode: widget.desiredCourseCode,
              title: widget.desiredTitle,
              professor: widget.desiredProfessor,
              day: widget.desiredDay,
              start: widget.desiredStart,
              end: widget.desiredEnd,
              room: widget.desiredRoom,
              credit: widget.desiredCredit,
              isRightAligned: false,
            ),

            const SizedBox(height: 20),

            // ---------------- NOTE AREA ----------------
            _buildNoteBox(currentNote),
            const SizedBox(height: 20),

            // ---------------- BOTTOM BUTTONS ----------------
            _bottomButtons(context),
          ],
        ),
      ),
    );
  }



  Widget _bottomButtons(BuildContext context) {
  const khured = Color(0xFF8B0000);

  // 1) 내가 쓴 글일 때
  if (myId == widget.authorId) {
    return Column(
      children: [
        Row(
          children: [
            // 수정
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () async {
                    final newNote = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditExchangePostScreen(
                          postUUID: widget.postUUID,
                          initialNote: currentNote,
                        ),
                      ),
                    );

                    if (newNote != null && newNote is String) {
                      setState(() => currentNote = newNote);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("게시글이 수정되었습니다.")),
                      );
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 삭제
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () async {
                    final confirm = await showDeleteConfirmDialog(context);
                    if (!confirm) return;

                    final result =
                        await ExchangeService.deletePost(widget.postUUID);

                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("게시글이 삭제되었습니다.")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("삭제 실패")),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 교환 수락 버튼 (글쓴이 + pending)
        if (_requestStatus == "pending" && _requestUUID != null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              minimumSize: const Size(0, 45),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final ok = await ExchangeService.acceptRequest(_requestUUID!);

              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("교환이 수락되었습니다.")),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("교환 수락 실패")),
                );
              }
            },
            child: const Text("교환 수락", style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  // 2) 내가 요청자일 때 → 취소 + 대화
  if (myId == _requesterId && _requestUUID != null) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              minimumSize: const Size(0, 45),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final ok =
                  await ExchangeService.cancelRequest(_requestUUID!);
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("요청이 취소되었습니다.")),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("요청 취소 실패")),
                );
              }
            },
            child: const Text("요청 취소", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 8),

        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: khured,
              minimumSize: const Size(0, 45),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final chatProvider = context.read<ChatProvider>();
              final roomId = await chatProvider.createChatRoom(
                postUUID: widget.postUUID,
                authorId: widget.authorId,
                peerId: myId!,
              );

              if (roomId != "-1") {
                await chatProvider.loadRooms(myId!);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      roomId: roomId,
                      userId: myId!,
                      peerId: widget.authorId,
                      postUUID: widget.postUUID,
                      postTitle:
                          "${widget.ownedTitle} ↔ ${widget.desiredTitle}",
                    ),
                  ),
                );
              }
            },
            child: const Text("대화 요청", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // 3) 남의 글일 때 → 교환 요청 + 대화
  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: khured,
            minimumSize: const Size(0, 45),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final requesterId = myId!;
            final ok = await ExchangeService.sendRequest(
              requesterId: requesterId,
              postUUID: widget.postUUID,
            );

            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("교환 요청을 보냈습니다.")),
              );

              setState(() {
                _requesterId = requesterId;
                _requestStatus = "pending";
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("요청 실패")),
              );
            }
          },
          child: const Text("교환 요청",
              style: TextStyle(color: Colors.white)),
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: khured,
            minimumSize: const Size(0, 45),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final chatProvider = context.read<ChatProvider>();
            final roomId = await chatProvider.createChatRoom(
              postUUID: widget.postUUID,
              authorId: widget.authorId,
              peerId: myId!,
            );

            if (roomId != "-1") {
              await chatProvider.loadRooms(myId!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    roomId: roomId,
                    userId: myId!,
                    peerId: widget.authorId,
                    postUUID: widget.postUUID,
                    postTitle:
                        "${widget.ownedTitle} ↔ ${widget.desiredTitle}",
                  ),
                ),
              );
            }
          },
          child: const Text("대화 요청",
              style: TextStyle(color: Colors.white)),
        ),
      ),
    ],
  );
  }


  // ---------------- NOTE BOX ----------------
  Widget _buildNoteBox(String note) {
    const textBrown = Color(0xFF3E2A25);
    const borderColor = Color(0xFFE2E2E2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "작성자 메모: ",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textBrown,
            ),
          ),
          Expanded(
            child: Text(
              note.isEmpty ? "작성자가 메모를 남기지 않았습니다." : note,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: textBrown.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SUBJECT DETAIL CARD ----------------
  Widget _buildSubjectDetailCard({
    required String label,
    required String title,
    required String courseCode,
    required String professor,
    required String day,
    required String start,
    required String end,
    required String room,
    required String credit,
    required bool isRightAligned,
  }) {
    const textBrown = Color(0xFF3E2A25);
    const cardWhite = Color(0xFFFFFFFF);
    const borderColor = Color(0xFFE2E2E2);
    const khured = Color(0xFF7A0E1D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: isRightAligned
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // LABEL
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: khured.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: khured.withOpacity(0.25),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: khured,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  "·",
                  style: TextStyle(
                    color: khured,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "[${courseCode}]",
                  style: const TextStyle(
                    color: khured,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // TITLE
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: textBrown,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // PROFESSOR
          Text(
            professor,
            style: TextStyle(
              color: textBrown.withOpacity(0.75),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // TIME + ROOM + CREDIT
          Text(
            "$day   $start~$end($room) $credit학점",
            style: TextStyle(
              color: textBrown.withOpacity(0.55),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


// ---------------- DELETE CONFIRM DIALOG ----------------

Future<bool> showDeleteConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "정말 삭제하시겠습니까?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "삭제하면 되돌릴 수 없습니다.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          "취소",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(0xFF8B0000),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          "삭제",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}


}
