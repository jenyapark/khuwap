import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class CreateExchangeScreen extends StatefulWidget {
  const CreateExchangeScreen({super.key});

  @override
  State<CreateExchangeScreen> createState() => _CreateExchangeScreenState();
}

class _CreateExchangeScreenState extends State<CreateExchangeScreen> {
  final storage = const FlutterSecureStorage();

  // 학수번호 + 비고만 입력받기
  final TextEditingController currentCourse = TextEditingController();
  final TextEditingController desiredCourse = TextEditingController();
  final TextEditingController note = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("교환글 작성")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "내가 가진 강의 (학수번호)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _input("예: CSE301", currentCourse),

            const SizedBox(height: 24),

            const Text(
              "원하는 강의 (학수번호)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _input("예: CSE202", desiredCourse),

            const SizedBox(height: 24),

            const Text(
              "비고 (선택)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _input("예: 시간대가 잘 맞아서 바꾸고 싶습니다.", note),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("등록하기"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => isLoading = true);

    final userId = await storage.read(key: "user_id");

    final body = {
      "author_id": userId,
      "current_course": currentCourse.text.trim(),
      "desired_course": desiredCourse.text.trim(),
      "note": note.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse("$coreUrl/exchange/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      setState(() => isLoading = false);

      // 생성 성공 코드: 201
      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        print("Create Failed: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error Occurred: $e");
    }
  }
}
