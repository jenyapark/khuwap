import 'package:flutter/material.dart';
import '../services/exchange_service.dart';

class EditExchangePostScreen extends StatefulWidget {
  final String postUUID;
  final String initialNote;

  const EditExchangePostScreen({
    super.key,
    required this.postUUID,
    required this.initialNote,
  });

  @override
  State<EditExchangePostScreen> createState() => _EditExchangePostScreenState();
}

class _EditExchangePostScreenState extends State<EditExchangePostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _noteController;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  Widget build(BuildContext context) {
    const deepRed = Color(0xFF8B0000);
    const deepBrown = Color(0xFF4A2A25);
    const ivory = Color(0xFFFAF8F3);

    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        elevation: 0,
        iconTheme: const IconThemeData(color: deepBrown),
        title: const Text(
          "메모 수정",
          style: TextStyle(color: deepBrown, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _noteController,
                maxLines: 5,
                style: const TextStyle(color: deepBrown),
                decoration: InputDecoration(
                  labelText: "메모",
                  labelStyle: const TextStyle(color: deepBrown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "메모를 입력하세요." : null,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
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

                          final success = await ExchangeService.updatePost(
                            widget.postUUID,
                            _noteController.text.trim(),
                          );

                          setState(() => loading = false);

                          if (success) {
                            if (!mounted) return;
                            Navigator.pop(context, _noteController.text.trim());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("수정 실패")),
                            );
                          }
                        },
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "수정 완료",
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
