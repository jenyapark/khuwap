import 'package:flutter/material.dart';
import 'package:khuwap_client/models/chat_room_item.dart';
import 'package:khuwap_client/screens/chat_screen.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart'; 
import '../providers/chat_provider.dart';

class ExchangeDetailScreen extends StatelessWidget {
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
    this.note = "",
    required this.authorId,
    required this.postUUID,

  });

  @override
  Widget build(BuildContext context) {
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

            // =================== OWNED CARD ===================
            _buildSubjectDetailCard(
              label: "owned",
              courseCode: ownedCourseCode,
              title: ownedTitle,
              professor: ownedProfessor,
              day: ownedDay,
              start: ownedStart,
              end: ownedEnd,
              room: ownedRoom,
              credit: ownedCredit,
              isRightAligned: false,
            ),

            const SizedBox(height: 20),

            // ================== DESIRED CARD ==================
            _buildSubjectDetailCard(
              label: "desired",
              courseCode: desiredCourseCode,
              title: desiredTitle,
              professor: desiredProfessor,
              day: desiredDay,
              start: desiredStart,
              end: desiredEnd,
              room: desiredRoom,
              credit: desiredCredit,
              isRightAligned: false,
            ),

            const SizedBox(height: 20),

            // ================== NOTE BOX ==================
            _buildNoteBox(note),
            const SizedBox(height: 20),

            // ================== REQUEST BUTTON ==================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: khured,
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "교환 요청",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================== CHAT BUTTON ==================
FutureBuilder<String?>(
  future: AuthService.getUserId(),
  builder: (context, snap) {
    if (!snap.hasData) return const SizedBox.shrink();

    final myId = snap.data!;

    final isMine = (myId == authorId);

    if (isMine) {
      return const SizedBox.shrink(); // 내 글이면 버튼 숨김
    }

    
  
 return Row(
  children: [
    // ============ 대화하기 버튼 (좌측) ============
    Expanded(
      flex: 7,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B0000),
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          final chatProvider = context.read<ChatProvider>();
          try {
            final String actualRoomId = await chatProvider.createChatRoom(
              postUUID: postUUID,
              authorId: authorId,
              peerId: myId,
            );

            if (actualRoomId != "-1") {
              await chatProvider.loadRooms(myId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    roomId: actualRoomId,
                    userId: myId,
                    postUUID: postUUID,
                    peerId: authorId,
                    postTitle: "${ownedTitle} ↔ ${desiredTitle}",
                  ),
                ),
              );
            }
          } catch (e) {
            print(">>> 방 생성 중 오류: $e");
          }
        },
        child: const Text(
          "대화하기",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    ),

    // ============ 수정 버튼 ============
    _roundIconButton(
      icon: Icons.edit,
      color: Colors.grey.shade700,
      onPressed: () {
        print("수정 버튼 클릭됨");
        // 수정 페이지 이동 이어야 됨
      },
    ),

    // ============ 삭제 버튼 ============
    _roundIconButton(
      icon: Icons.delete,
      color: Colors.red.shade700,
      onPressed: () {
        print("삭제 버튼 클릭됨");
        // 삭제 로직 이어야 함
      },
    ),
  ],
);
  }
)

            
          ],
        ),
      ),
    );
  }
  
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

        // note 내용이 길어도 자동 줄바꿈
        Expanded(
          child: Text(
            (note.isEmpty)
                ? "작성자가 메모를 남기지 않았습니다."
                : note,
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

Widget _roundIconButton({
  required IconData icon,
  required Color color,
  required VoidCallback onPressed,
}) {
  return Container(
    width: 50,
    height: 50,
    margin: const EdgeInsets.only(left: 10),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
    ),
    child: IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
    ),
  );
}



  // ============== SUBJECT DETAIL CARD ==================
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
          // ---------- LABEL ----------
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
      // owned / desired
      Text(
        label,
        style: const TextStyle(
          color: khured,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      const SizedBox(width: 4),

      // 가운데 점 (·)
      const Text(
        "·",
        style: TextStyle(
          color: khured,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      const SizedBox(width: 4),

      // 학수번호
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

          // ---------- TITLE ----------
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

          // ---------- PROFESSOR ----------
          Text(
            professor,
            style: TextStyle(
              color: textBrown.withOpacity(0.75),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // ---------- TIME ----------
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
}