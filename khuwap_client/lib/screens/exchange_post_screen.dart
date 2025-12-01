import 'package:flutter/material.dart';
import '../services/exchange_service.dart';
import '../services/auth_service.dart';

class CreateExchangePostScreen extends StatefulWidget {
  const CreateExchangePostScreen({super.key});

  @override
  State<CreateExchangePostScreen> createState() => _CreateExchangePostScreenState();
}

class _CreateExchangePostScreenState extends State<CreateExchangePostScreen> {
  final _formKey = GlobalKey<FormState>();

  String ownedTitle = "";
  String ownedCourseCode = "";
  String desiredCourseCode = "";
  String note = "";

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    const deepRed = Color(0xFF8B0000);
    const ivory = Color(0xFFFAF8F3);

    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "교환글 작성",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: deepRed,
          ),
        ),
        iconTheme: const IconThemeData(color: deepRed),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("현재 과목", (v) => ownedCourseCode = v),
              buildTextField("희망 과목", (v) => desiredCourseCode = v),
              buildTextField("메모", (v) => note = v),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => loading = true);

                          final userId = await AuthService.getUserId();

                          final success = await ExchangeService.createPost(
                            authorId: userId!,
                            ownedCourseCode: ownedCourseCode!,
                            desiredCourseCode: desiredCourseCode!,
                            note: note,
                          );

                          setState(() => loading = false);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("게시글이 등록되었습니다.")),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("등록에 실패했습니다.")),
                            );
                          }
                        },
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("등록하기", style: TextStyle(fontSize: 16, color: Colors.white,)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, Function(String) onSaved,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        maxLines: maxLines,
        style: const TextStyle(color: Color(0xFF4A2A25)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4A2A25)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? "값을 입력해주세요"
            : null,
        onChanged: onSaved,
      ),
    );
  }
}
