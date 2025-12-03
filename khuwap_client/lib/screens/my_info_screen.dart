import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class MyInfoScreen extends StatefulWidget {
  final String userId;

  const MyInfoScreen({super.key, required this.userId});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await UserService.fetchUserById(widget.userId);
    setState(() {
      user = data;
      isLoading = false;
    });
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
          "내 정보",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: deepBrown,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // ---------------- PROFILE IMAGE ----------------
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: deepBrown,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ---------------- USERNAME ----------------
                  Text(
                    user?["username"] ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: deepBrown,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ---------------- EMAIL ----------------
                  Text(
                    user?["email"] ?? "",
                    style: TextStyle(
                      fontSize: 15,
                      color: deepBrown.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ---------------- INFO CARD ----------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Color(0xFFEDEDED)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow("사용자 ID", user?["user_id"] ?? ""),
                        const SizedBox(height: 18),
                        _buildInfoRow(
                            "최대 신청 학점",
                            user?["max_credit"]?.toString() ?? ""
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ---------------- LOGOUT BUTTON ----------------
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        await AuthService.logout();
                        if (!context.mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/login",
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: khured,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "로그아웃",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    const deepBrown = Color(0xFF3E2A25);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: deepBrown.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: deepBrown,
          ),
        ),
      ],
    );
  }
}
