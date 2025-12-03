import 'package:flutter/material.dart';
import '../services/timetable_service.dart';

class TimeTableAddScreen extends StatefulWidget {
  final String userId;

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

      if (response == true) {
        Navigator.pop(context, true);
        return;
      }

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
    const deepBrown = Color(0xFF3E2A25);
    const khured = Color(0xFF7A0E1D);

    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "시간표 추가",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: deepBrown,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------------- 사용자 ID ----------------
              Text(
                "사용자 ID",
                style: TextStyle(
                  color: deepBrown.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xFFE2E2E2)),
                ),
                child: Text(
                  widget.userId,
                  style: const TextStyle(
                    color: deepBrown,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ---------------- 과목코드 ----------------
              Text(
                "과목 코드",
                style: TextStyle(
                  color: deepBrown.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),

              TextField(
                controller: _courseCodeController,
                decoration: InputDecoration(
                  hintText: "예: CSE30100",
                  hintStyle: TextStyle(color: deepBrown.withOpacity(0.45)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                ),
                style: const TextStyle(
                  color: deepBrown,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // ---------------- 버튼 ----------------
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: khured,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "추가하기",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
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
}
