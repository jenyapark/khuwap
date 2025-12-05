import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import '../config/api.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 각 입력 필드 컨트롤러
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController maxCreditController = TextEditingController();

  bool _obscurePassword = true; // 비밀번호 가리기용

  @override
  Widget build(BuildContext context) {
    // 공통 입력 스타일
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B0000)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "회원가입",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "계정을 만들고 앱을 이용해보세요!",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 32),

              // 학번
              TextFormField(
                controller: userIdController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration.copyWith(labelText: "학번"),
              ),
              const SizedBox(height: 16),

              // 이름
              TextFormField(
                controller: usernameController,
                decoration: inputDecoration.copyWith(labelText: "이름"),
              ),
              const SizedBox(height: 16),

              // 이메일
              TextFormField(
                controller: emailController,
                decoration: inputDecoration.copyWith(labelText: "이메일"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // 비밀번호
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: inputDecoration.copyWith(
                  labelText: "비밀번호",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 최대 수강 학점
              TextFormField(
                controller: maxCreditController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration.copyWith(labelText: "최대 수강 학점"),
              ),
              const SizedBox(height: 32),

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse('$coreUrl/users/register');

                    final body = jsonEncode({
                      "user_id": userIdController.text,
                      "username": usernameController.text,
                      "email": emailController.text,
                      "password": passwordController.text,
                      "max_credit":
                          int.tryParse(maxCreditController.text) ?? 18,
                    });

                    try {
                      final response = await http.post(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: body,
                      );

                      if (!mounted) return;
                      if (response.statusCode == 201) {
                        _showCustomDialog(
                          context,
                          "회원가입이 완료되었습니다!",
                          success: true,
                        );
                      } else if (response.statusCode == 400) {
                        final responseData = jsonDecode(response.body);
                        final message =
                            responseData['message'] ?? "회원가입에 실패했습니다.";
                        _showCustomDialog(context, message);
                      } else {
                        _showCustomDialog(
                          context,
                          "회원가입에 실패했습니다.\n잠시 후 다시 시도해주세요.",
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      _showCustomDialog(context, "서버에 연결할 수 없습니다.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 로그인 안내
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "이미 계정이 있습니까? ",
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "로그인하세요",
                      style: TextStyle(
                        color: Color(0xFF8B0000),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

void _showCustomDialog(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000), // 경희대 레드
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context); // 팝업 닫기
                if (success) {
                  // 로그인 화면으로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              child: const Text(
                "확인",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
