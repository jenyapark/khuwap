import 'package:flutter/material.dart';

class ExchangeDetailScreen extends StatelessWidget {
  final String ownedTitle;
  final String ownedProfessor;
  final String ownedDay;
  final String ownedStart;
  final String ownedEnd;

  final String desiredTitle;
  final String desiredProfessor;
  final String desiredDay;
  final String desiredStart;
  final String desiredEnd;

  const ExchangeDetailScreen({
    super.key,
    required this.ownedTitle,
    required this.ownedProfessor,
    required this.ownedDay,
    required this.ownedStart,
    required this.ownedEnd,
    required this.desiredTitle,
    required this.desiredProfessor,
    required this.desiredDay,
    required this.desiredStart,
    required this.desiredEnd,
  });

  @override
  Widget build(BuildContext context) {
    const kyeongheeRed = Color(0xFFB5121B);
    const background = Color(0xFF0F1824);
    const cardBg = Color(0xFF1C2833);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "KHUWAP",
          style: TextStyle(
            color: kyeongheeRed,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person_outline, color: Colors.white, size: 28),
          ),
        ],
      ),

      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --------------------- TOP TAGS ---------------------
              Row(
                children: [
                  _buildTag("desired"),
                  const Spacer(),
                  _buildTag("owned"),
                ],
              ),

              const SizedBox(height: 14),

              // ------------------ SUBJECT CARDS -------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSubjectCard(
                      title: desiredTitle,
                      professor: desiredProfessor,
                      day: desiredDay,
                      start: desiredStart,
                      end: desiredEnd,
                      alignRight: false,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _buildSubjectCard(
                      title: ownedTitle,
                      professor: ownedProfessor,
                      day: ownedDay,
                      start: ownedStart,
                      end: ownedEnd,
                      alignRight: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // ---------------- REQUEST BUTTON (FULL) --------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kyeongheeRed,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "요청하기",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ---------------- SMALL BACK BUTTON -----------------
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "뒤로가기",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- TAGS ----------------------
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  // ----------------- SUBJECT CARD -------------------
  Widget _buildSubjectCard({
    required String title,
    required String professor,
    required String day,
    required String start,
    required String end,
    required bool alignRight,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          professor,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$day  $start~$end",
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}