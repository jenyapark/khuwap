import 'package:flutter/material.dart';
import 'package:khuwap_client/screens/home_body.dart';
import 'package:khuwap_client/screens/timetable_screen.dart';
import 'package:khuwap_client/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await AuthService.getUserId();
    setState(() {
      userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    const ivory = Color(0xFFFAF8F3);
    const deepRed = Color(0xFF8B0000);
    const deepBrown = Color(0xFF4A2A25);

    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      const HomeBody(),                     // ← 네가 만든 기존 UI
      TimeTableScreen(userId: userId!),     // ← 시간표 스크린 연결
      const Center(child: Text("Message")), // 구현 전이라 그냥 placeholder
      const Center(child: Text("Request")),
      const Center(child: Text("My Post")),
    ];

    return Scaffold(
      backgroundColor: ivory,
      body: screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
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
}
