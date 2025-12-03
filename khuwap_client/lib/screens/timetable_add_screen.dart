import 'package:flutter/material.dart';
import '../services/timetable_service.dart';

class TimeTableAddScreen extends StatefulWidget {
  final String userId; // 이미 로그인한 사용자 ID

  const TimeTableAddScreen({
    super.key,
    required this.userId,
  });

  @override
  State<TimeTableAddScreen> createState() => _TimeTableAddScreenState();
}

class _TimeTableAddScreenState extends State<TimeTableAddScreen> {
  final TextEditingController _courseCodeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final courseCode = _courseCodeController.text.trim();

    if (courseCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("과목 코드를 입력해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await TimeTableService.addTimetable(
        userId: widget.userId,
        courseCode: courseCode,
      );

      // 성공
      if (response == true) {
        Navigator.pop(context, true);
        return;
      }

      // 실패
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("시간표 추가에 실패했습니다.")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const ivory = Color(0xFFFAF8F3);

    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        elevation: 0,
        title: const Text(
          "시간표 추가",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF3E2A25),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // user_id 고정 값 표시
            const Text(
              "사용자 ID",
              style: TextStyle(
                color: Color(0xFF3E2A25),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE2E2E2)),
              ),
              child: Text(
                widget.userId,
                style: const TextStyle(
                  color: Color(0xFF3E2A25),
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // course code 입력
            const Text(
              "과목 코드",
              style: TextStyle(
                color: Color(0xFF3E2A25),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _courseCodeController,
              decoration: InputDecoration(
                hintText: "예: CSE30100",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                ),
              ),
            ),

            const Spacer(),

            // 제출 버튼
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A0E1D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "추가하기",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
