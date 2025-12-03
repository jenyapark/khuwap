import 'package:flutter/material.dart';
import '../services/timetable_service.dart';
import '../models/timetable_item.dart';
import '../screens/timetable_add_screen.dart';
import '../screens/timetable_delete_screen.dart';

class TimeTableScreen extends StatefulWidget {
  final String userId; // 로그인한 사용자 학번
  const TimeTableScreen({super.key, required this.userId});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  @override
  Widget build(BuildContext context) {
    const ivory = Color(0xFFFAF8F3);

    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "시간표",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF3E2A25),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, size: 28),
            color: const Color(0xFF3E2A25),
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TimeTableAddScreen(userId: widget.userId),
                ),
              );

              if (added == true) {
                setState(() {});
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_rounded, size: 28),
            color: const Color(0xFF7A0E1D),
            onPressed: () async {
              final deleted = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TimeTableDeleteScreen(userId: widget.userId),
                ),
              );

              if (deleted == true) {
                setState(() {});
              }
            },
          ),
        ],
      ),

      body: FutureBuilder<List<TimeTableItem>>(
        future: TimeTableService.fetchComposedTimetable(widget.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text(
                "등록된 시간표가 없습니다.",
                style: TextStyle(fontSize: 16, color: Color(0xFF3E2A25)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSubjectDetailCard(
                  label: "owned",
                  title: item.courseName,
                  courseCode: item.courseCode,
                  professor: item.professor,
                  day: item.day,
                  start: item.startTime,
                  end: item.endTime,
                  room: item.room,
                  credit: item.credit.toString(),
                  isRightAligned: false,
                ),
              );
            },
          );
        },
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
              border: Border.all(color: khured.withOpacity(0.25), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // label
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

                // courseCode
                Text(
                  "[$courseCode]",
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
            "$day   $start~$end($room) ${credit}학점",
            style: TextStyle(color: textBrown.withOpacity(0.55), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
