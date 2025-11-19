import 'package:flutter/material.dart';
import 'exchange_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    const ivory = Color(0xFFFAF8F3);         // 전체 배경
    const deepRed = Color(0xFF8B0000);       // 경희레드
    const deepBrown = Color(0xFF4A2A25);     // 텍스트 주색

    final List<Map<String, String>> dummyExchangeData = [
  {
    // ----------------- OWNED -----------------
    "ownedTitle": "고급자료구조와 알고리즘",
    "ownedProfessor": "김상철",
    "ownedDay": "월/수",
    "ownedStart": "10:00",
    "ownedEnd": "11:15",
    "ownedCourseCode": "CSE301",
    "ownedRoom": "B09",
    "ownedCredit": "3",

    // ----------------- DESIRED -----------------
    "desiredTitle": "운영체제",
    "desiredProfessor": "이은정",
    "desiredDay": "화/목",
    "desiredStart": "13:00",
    "desiredEnd": "14:15",
    "desiredCourseCode": "CSE202",
    "desiredRoom": "공학관207",
    "desiredCredit" : "3",

    // ----------------- NOTE -----------------
    "note": "시간이 딱 맞아서 바꾸고 싶어요!",
  },

  {
    // ----------------- OWNED -----------------
    "ownedTitle": "데이터베이스 시스템 설계",
    "ownedProfessor": "박지훈",
    "ownedDay": "화/목",
    "ownedStart": "09:00",
    "ownedEnd": "10:15",
    "ownedCourseCode": "CSE305",
    "ownedRoom": "신공학관302",

    // ----------------- DESIRED -----------------
    "desiredTitle": "컴퓨터네트워크",
    "desiredProfessor": "정소민",
    "desiredDay": "월/수",
    "desiredStart": "14:00",
    "desiredEnd": "15:15",
    "desiredCourseCode": "CSE211",
    "desiredRoom": "B12",

    // ----------------- NOTE -----------------
    "note": "과목 난이도 차이 때문에 바꾸고 싶습니다.",
  },
];


    return Scaffold(
      backgroundColor: ivory,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------- HEADER -------------------------
              Row(
                children: [
                  Icon(Icons.school, color: deepRed, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    "khuwap",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: deepBrown,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.person_outline, color: deepBrown, size: 30),
                ],
              ),

              const SizedBox(height: 20),

              // ------------------------- SEARCH BAR -------------------------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: deepBrown.withOpacity(0.25), width: 1.2),
                ),
                child: TextField(
                  style: TextStyle(color: deepBrown, fontSize: 15),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: deepBrown.withOpacity(0.6)),
                    border: InputBorder.none,
                    hintText: "Search for subjects...",
                    hintStyle: TextStyle(color: deepBrown.withOpacity(0.45)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------- LIST VIEW -------------------------
              Expanded(
                child: ListView.builder(
                  itemCount: dummyExchangeData.length,
                  itemBuilder: (context, index) {
                    final item = dummyExchangeData[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExchangeDetailScreen(
                              ownedTitle: item["ownedTitle"]!,
                              ownedProfessor: item["ownedProfessor"]!,
                              ownedDay: item["ownedDay"]!,
                              ownedStart: item["ownedStart"]!,
                              ownedEnd: item["ownedEnd"]!,
                              ownedCourseCode: item["ownedCourseCode"]!,
      ownedRoom: item["ownedRoom"]!,
      ownedCredit: item["ownedCredit"]!,
                              desiredTitle: item["desiredTitle"]!,
                              desiredProfessor: item["desiredProfessor"]!,
                              desiredDay: item["desiredDay"]!,
                              desiredStart: item["desiredStart"]!,
                              desiredEnd: item["desiredEnd"]!,
                              desiredCourseCode: item["desiredCourseCode"]!,
      desiredRoom: item["desiredRoom"]!,
      desiredCredit: item["desiredCredit"]!,
                              note: item["note"] ?? "",
                            ),
                          ),
                        );
                      },
                      child: _buildExchangeCard(
                        item: item,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ------------------------- FAB -------------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: deepRed,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),

      // ------------------------- NAV BAR -------------------------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ivory,
        selectedItemColor: deepRed,
        unselectedItemColor: deepBrown.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Message"),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "Request"),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: "My Post"),
        ],
      ),
    );
  }
  
  Widget _buildExchangeCard({
  required Map<String, String> item,
}) {
  const borderColor = Color(0xFFE2E2E2);
  const textColor = Color(0xFF3E2A25);
  const kehured = Color(0xFF7A0E1D);  // 경희레드

  String schedule(String d, String s, String e) => "$d  $s-$e";

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    height: 145,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // ---------------- BACKGROUND CARD ----------------
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1),
          ),
        ),

        // ---------------- SWAP ICON (CENTER) ----------------
        
      
Stack(
  alignment: Alignment.center,
  children: [
    // 아래(윤곽선 역할)
    Icon(
      Icons.swap_horiz,
      size: 44,          
      color: Color(0xFF4A2A25),   // 윤곽선 색 (딥브라운 등)
      weight: 900,
    ),

    // 위(본체)
    Icon(
      Icons.swap_horiz,
      size: 40,            
      color: Color(0xFF7A0E1D),   // 경희레드 (본색)
      weight: 900,
    ),
  ],
),

        // ---------------- LEFT + RIGHT CONTENT ----------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              // ---------------- LEFT (OWNED) ----------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LABEL
                    Text(
                      "owned",
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // TITLE
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        item["ownedTitle"]!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // PROFESSOR + TIME
                    Text(
                      item["ownedProfessor"]!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.1,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      schedule(item["ownedDay"]!,
                          item["ownedStart"]!, item["ownedEnd"]!),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.1,
                        color: textColor.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------- RIGHT (DESIRED) ----------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // LABEL
                    Text(
                      "desired",
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // TITLE
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 130,    // ⬅ 오른쪽도 폭 제한
                      ),
                      child: Text(
                        item["desiredTitle"]!,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),


                    const Spacer(),

                    // PROFESSOR + TIME
                    Text(
                      item["desiredProfessor"]!,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      schedule(item["desiredDay"]!,
                          item["desiredStart"]!, item["desiredEnd"]!),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}
}